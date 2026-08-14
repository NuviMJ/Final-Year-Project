import 'package:go_router/go_router.dart';

import '../../features/assessment/presentation/assessment_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/history/presentation/past_result_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/medications/presentation/medication_selection_screen.dart';
import '../../features/prediction/presentation/result_screen.dart';
import '../../features/startup/presentation/splash_screen.dart';
import '../../features/trends/presentation/trends_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String medications = '/medications';
  static const String assessment = '/assessment';
  static const String result = '/result';
  static const String history = '/history';
  static const String trends = '/trends';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.medications,
      name: 'medications',
      builder: (_, __) => const MedicationSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.assessment,
      name: 'assessment',
      builder: (_, __) => const AssessmentScreen(),
    ),
    GoRoute(
      path: AppRoutes.result,
      name: 'result',
      builder: (_, __) => const ResultScreen(),
    ),
    GoRoute(
      path: AppRoutes.trends,
      name: 'trends',
      builder: (_, __) => const TrendsScreen(),
    ),
    GoRoute(
      path: AppRoutes.history,
      name: 'history',
      builder: (_, __) => const HistoryScreen(),
      routes: <RouteBase>[
        // Nested, so /history/<id> keeps the list as its parent and the back
        // button returns there rather than to the home screen.
        GoRoute(
          path: ':id',
          name: 'pastResult',
          builder: (_, GoRouterState state) =>
              PastResultScreen(recordId: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
);
