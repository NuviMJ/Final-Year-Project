import 'package:flutter/material.dart';

import 'core/config/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/setup_status_screen.dart';

/// Root widget of the QoLGuard application.
///
/// Stage 3 replaces `home` with `MaterialApp.router` and the go_router
/// configuration, including the authentication redirect guard.
class QoLGuardApp extends StatelessWidget {
  const QoLGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const SetupStatusScreen(),
    );
  }
}
