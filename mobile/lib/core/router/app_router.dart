import 'package:go_router/go_router.dart';

import '../../features/assessment/presentation/assessment_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/history/presentation/past_result_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/learn/presentation/learn_screen.dart';
import '../../features/medications/presentation/medication_selection_screen.dart';
import '../../features/prediction/presentation/result_screen.dart';
import '../../features/reminders/presentation/edit_reminder_screen.dart';
import '../../features/reminders/presentation/reminders_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/startup/presentation/splash_screen.dart';
import '../../features/trends/presentation/trends_screen.dart';
import '../widgets/app_shell.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String medications = '/medications';
  static const String assessment = '/assessment';
  static const String result = '/result';
  static const String history = '/history';
  static const String trends = '/trends';
  static const String reminders = '/reminders';
  static const String addReminder = '/reminders/new';
  static const String learn = '/learn';
  static const String settings = '/settings';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (_, __) => const SplashScreen(),
    ),
    // Home, Reminders and Trends share a bottom bar. Each keeps its own
    // navigation stack, so switching tabs does not reset the others.
    StatefulShellRoute.indexedStack(
      builder: (_, __, StatefulNavigationShell shell) =>
          AppShell(navigationShell: shell),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              builder: (_, __) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.reminders,
              name: 'reminders',
              builder: (_, __) => const RemindersScreen(),
              routes: <RouteBase>[
                // 'new' is declared before ':id' so it is matched as the add
                // screen rather than a reminder whose id is the word "new".
                GoRoute(
                  path: 'new',
                  name: 'addReminder',
                  builder: (_, __) => const EditReminderScreen(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'editReminder',
                  builder: (_, GoRouterState state) =>
                      EditReminderScreen(reminderId: state.pathParameters['id']),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.trends,
              name: 'trends',
              builder: (_, __) => const TrendsScreen(),
            ),
          ],
        ),
      ],
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
      path: AppRoutes.learn,
      name: 'learn',
      builder: (_, __) => const LearnScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: ':id',
          name: 'article',
          builder: (_, GoRouterState state) =>
              ArticleScreen(articleId: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (_, __) => const SettingsScreen(),
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
