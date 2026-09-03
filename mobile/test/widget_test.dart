import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qolguard/core/router/app_router.dart';

import 'package:qolguard/core/network/api_exception.dart';
import 'package:qolguard/features/medications/domain/medication.dart';
import 'package:qolguard/features/startup/data/health_repository.dart';
import 'package:qolguard/features/startup/presentation/splash_screen.dart';
import 'package:qolguard/features/startup/presentation/widgets/pulse_line.dart';

void main() {
  group('ApiException', () {
    test('a connection failure is reported as unreachable, not as a crash', () {
      final ApiException exception = ApiException.from(
        DioException(
          requestOptions: RequestOptions(path: '/health'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(exception.failure, ApiFailure.unreachable);
      expect(exception.message, contains('Cannot reach'));
    });

    test('a 422 carries the offending field so a form can mark it', () {
      // Mirrors the body FastAPI returns when a value is out of range.
      final ApiException exception = ApiException.from(
        DioException.badResponse(
          statusCode: 422,
          requestOptions: RequestOptions(path: '/predict'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/predict'),
            statusCode: 422,
            data: <String, dynamic>{
              'detail': <dynamic>[
                <String, dynamic>{
                  'loc': <dynamic>['body', 'Age'],
                  'msg': 'Input should be greater than or equal to 18',
                  'type': 'greater_than_equal',
                },
              ],
            },
          ),
        ),
      );

      expect(exception.isValidation, isTrue);
      expect(exception.fieldErrors['Age'], contains('18'));
    });

    test('a 404 surfaces the server’s own explanation', () {
      final ApiException exception = ApiException.from(
        DioException.badResponse(
          statusCode: 404,
          requestOptions: RequestOptions(path: '/predict'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/predict'),
            statusCode: 404,
            data: <String, dynamic>{'detail': 'Unsupported medication: Warfarin'},
          ),
        ),
      );

      expect(exception.failure, ApiFailure.notFound);
      expect(exception.message, contains('Warfarin'));
    });
  });

  group('Medication', () {
    test('parses the drug endpoint payload and formats its dose range', () {
      final Medication medication = Medication.fromJson(<String, dynamic>{
        'name': 'Atorvastatin',
        'drug_class': 'Statins',
        'dose_unit': 'mg/day',
        'dose_min': 10,
        'dose_max': 80,
        'typical_doses': <dynamic>[10, 20, 40, 80],
      });

      expect(medication.name, 'Atorvastatin');
      expect(medication.doseRangeLabel, '10–80 mg/day');
      expect(medication.typicalDoses, hasLength(4));
    });
  });

  group('SplashScreen', () {
    testWidgets('reports a clear message when the backend is unreachable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            serviceStatusProvider.overrideWith(
              (ref) => throw const ApiException(
                failure: ApiFailure.unreachable,
                message: 'Cannot reach the QoLGuard server.',
              ),
            ),
          ],
          child: const MaterialApp(home: SplashScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Cannot reach the server'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('shows the wordmark and tagline while connecting',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Never completes, so the branding state stays on screen.
            serviceStatusProvider.overrideWith(
              (ref) => Completer<ServiceStatus>().future,
            ),
          ],
          child: const MaterialApp(home: SplashScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Connecting…'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('PulseLinePainter', () {
    test('repaints only when something it draws has changed', () {
      const PulseLinePainter base =
          PulseLinePainter(progress: 0.5, color: Color(0xFF0F766E));

      expect(
        base.shouldRepaint(
          const PulseLinePainter(progress: 0.5, color: Color(0xFF0F766E)),
        ),
        isFalse,
      );
      expect(
        base.shouldRepaint(
          const PulseLinePainter(progress: 0.6, color: Color(0xFF0F766E)),
        ),
        isTrue,
      );
    });
  });

  group('App shell', () {
    RouteBase? shellRoute() {
      for (final RouteBase route in appRouter.configuration.routes) {
        if (route is StatefulShellRoute) return route;
      }
      return null;
    }

    List<String> pathsIn(StatefulShellBranch branch) => <String>[
          for (final RouteBase route in branch.routes)
            if (route is GoRoute) route.path,
        ];

    test('Home, Reminders and Trends share one tabbed shell', () {
      final StatefulShellRoute shell = shellRoute()! as StatefulShellRoute;

      expect(shell.branches.length, 3);
      expect(pathsIn(shell.branches[0]), contains(AppRoutes.home));
      expect(pathsIn(shell.branches[1]), contains(AppRoutes.reminders));
      expect(pathsIn(shell.branches[2]), contains(AppRoutes.trends));
    });

    test('every destination but the splash sits inside the shell', () {
      final StatefulShellRoute shell = shellRoute()! as StatefulShellRoute;
      final List<String> inShell = <String>[
        for (final StatefulShellBranch branch in shell.branches)
          ...pathsIn(branch),
      ];

      // The bottom bar shows on every screen the patient can reach.
      for (final String path in <String>[
        AppRoutes.home,
        AppRoutes.medications,
        AppRoutes.assessment,
        AppRoutes.result,
        AppRoutes.history,
        AppRoutes.learn,
        AppRoutes.settings,
        AppRoutes.reminders,
        AppRoutes.trends,
      ]) {
        expect(inShell, contains(path), reason: '$path has no bottom bar');
      }

      final List<String> topLevel = <String>[
        for (final RouteBase route in appRouter.configuration.routes)
          if (route is GoRoute) route.path,
      ];
      expect(topLevel, <String>[AppRoutes.splash]);
    });

    test('editing a reminder stays inside the Reminders tab', () {
      final StatefulShellRoute shell = shellRoute()! as StatefulShellRoute;
      final GoRoute reminders = shell.branches[1].routes.first as GoRoute;

      expect(
        <String>[
          for (final RouteBase route in reminders.routes)
            if (route is GoRoute) route.path,
        ],
        <String>['new', ':id'],
      );
    });
  });
}
