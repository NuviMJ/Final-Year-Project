import 'package:go_router/go_router.dart';

import '../../features/medications/presentation/medication_selection_screen.dart';
import '../../features/startup/presentation/startup_screen.dart';

/// Application routes.
///
/// The startup route is the entry point deliberately: it verifies the backend
/// is reachable before any assessment can begin, so a connectivity problem is
/// reported once, up front, rather than as a failure part-way through a form
/// the patient has already filled in.
abstract final class AppRoutes {
  static const String startup = '/';
  static const String medications = '/medications';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.startup,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.startup,
      name: 'startup',
      builder: (_, __) => const StartupScreen(),
    ),
    GoRoute(
      path: AppRoutes.medications,
      name: 'medications',
      builder: (_, __) => const MedicationSelectionScreen(),
    ),
  ],
);
