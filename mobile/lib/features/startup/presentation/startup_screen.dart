import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_state_views.dart';
import '../data/health_repository.dart';

/// Confirms the backend is reachable before the assessment can be started.
///
/// This screen exists because of one specific failure: on an Android emulator
/// `localhost` means the emulator itself, not the development machine, so a
/// misconfigured base URL produces a request that simply never returns. Calling
/// `/health` up front turns that silent hang into a message naming the address
/// the app is actually using.
class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ServiceStatus> status = ref.watch(serviceStatusProvider);

    return Scaffold(
      body: SafeArea(
        child: status.when(
          loading: () => const AppLoadingView(message: 'Connecting to QoLGuard…'),
          error: (Object error, StackTrace _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(serviceStatusProvider),
          ),
          data: (ServiceStatus service) => _Ready(status: service),
        ),
      ),
    );
  }
}

class _Ready extends StatelessWidget {
  const _Ready({required this.status});

  final ServiceStatus status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Spacer(),
          Center(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.health_and_safety_outlined,
                size: 44,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppConstants.appName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.appTagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.check_circle_outline,
                    size: 20, color: AppColors.riskLow),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Connected', style: theme.textTheme.labelLarge),
                      Text(
                        '${status.supportedDrugs} medications · '
                        'model ${status.modelVersion}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go('/medications'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Start assessment'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppConstants.medicalDisclaimer,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
