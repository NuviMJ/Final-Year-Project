import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qolguard/core/network/api_exception.dart';
import 'package:qolguard/features/medications/domain/medication.dart';
import 'package:qolguard/features/startup/data/health_repository.dart';
import 'package:qolguard/features/startup/presentation/startup_screen.dart';

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

  group('StartupScreen', () {
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
          child: const MaterialApp(home: StartupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cannot reach the server'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('shows the loaded model once the backend answers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            serviceStatusProvider.overrideWith(
              (ref) async => const ServiceStatus(
                appName: 'QoLGuard API',
                version: '0.1.0',
                modelLoaded: true,
                modelVersion: 'xgboost-3class-49f-300r',
                supportedDrugs: 10,
              ),
            ),
          ],
          child: const MaterialApp(home: StartupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Connected'), findsOneWidget);
      expect(find.textContaining('10 medications'), findsOneWidget);
      expect(find.text('Start assessment'), findsOneWidget);
    });
  });
}
