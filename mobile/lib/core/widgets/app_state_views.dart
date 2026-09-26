import 'package:flutter/material.dart';

import '../network/api_error_text.dart';
import '../network/api_exception.dart';
import '../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Shown while a request is in flight.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          if (message != null) ...<Widget>[
            const SizedBox(height: 20),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Shown when a request fails.
///
/// Deliberately distinguishes "cannot reach the server" from every other
/// failure, because that case has a specific and actionable cause during
/// development — the backend is not running, or the app is pointed at the
/// wrong address — and a generic "something went wrong" hides it.
class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ApiException? api = error is ApiException ? error as ApiException : null;
    final bool unreachable = api?.failure == ApiFailure.unreachable;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              unreachable ? Icons.cloud_off_outlined : Icons.error_outline,
              size: 48,
              color: AppColors.riskMedium,
            ),
            const SizedBox(height: 16),
            Text(
              unreachable ? l10n.errorUnreachableTitle : l10n.errorGenericTitle,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              api?.localized(l10n) ?? error.toString(),
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.coreTryAgain),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
