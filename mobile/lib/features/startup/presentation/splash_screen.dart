import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../history/data/assessment_store.dart';
import '../data/health_repository.dart';
import 'widgets/pulse_line.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _minimumDisplay = Duration(milliseconds: 1600);

  late final AnimationController _controller;
  late final Animation<double> _markFade;
  late final Animation<double> _markScale;
  late final Animation<double> _taglineFade;
  late final Animation<double> _pulse;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _markFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.32, curve: Curves.easeOut),
    );
    _markScale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.42, curve: Curves.easeOutCubic),
      ),
    );
    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.55, curve: Curves.easeOut),
    );
    // The trace draws itself left to right, like a monitor writing a beat.
    _pulse = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeInOut),
    );

    _controller.forward();
    _openWhenReady();
  }

  Future<void> _openWhenReady() async {
    final Stopwatch clock = Stopwatch()..start();
    try {
      // Local storage is opened here rather than lazily, so every screen after
      // the splash can read stored assessments synchronously.
      await ref.read(sharedPreferencesProvider.future);
      await ref.read(serviceStatusProvider.future);
    } catch (_) {
      // Rendered by the error branch in build(); nothing to do here.
      return;
    }

    final Duration remaining = _minimumDisplay - clock.elapsed;
    if (remaining > Duration.zero) await Future<void>.delayed(remaining);

    if (!mounted || _navigated) return;
    _navigated = true;
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ServiceStatus> status = ref.watch(serviceStatusProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: status.hasError
            ? AppErrorView(
                error: status.error!,
                onRetry: () {
                  ref.invalidate(serviceStatusProvider);
                  _openWhenReady();
                },
              )
            : _Branding(
                controller: _controller,
                markFade: _markFade,
                markScale: _markScale,
                taglineFade: _taglineFade,
                pulse: _pulse,
              ),
      ),
    );
  }
}

class _Branding extends StatelessWidget {
  const _Branding({
    required this.controller,
    required this.markFade,
    required this.markScale,
    required this.taglineFade,
    required this.pulse,
  });

  final AnimationController controller;
  final Animation<double> markFade;
  final Animation<double> markScale;
  final Animation<double> taglineFade;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: <Widget>[
          const Spacer(flex: 3),
          FadeTransition(
            opacity: markFade,
            child: ScaleTransition(
              scale: markScale,
              child: Image.asset(
                'assets/images/QoLGuard_wordmark.png',
                width: 280,
                fit: BoxFit.contain,
              
                semanticLabel: '${AppConstants.appName} logo',
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 44,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (BuildContext context, Widget? child) => CustomPaint(
                painter: PulseLinePainter(
                  progress: pulse.value,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: taglineFade,
            child: Text(
              AppConstants.appTagline,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const Spacer(flex: 4),
          FadeTransition(
            opacity: taglineFade,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 14),
                Text(
                  'Connecting…',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
