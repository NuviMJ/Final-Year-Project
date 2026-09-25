import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

/// Holds the three tabbed destinations and the bar that switches between them.
///
/// The assessment flow, history, learn and settings sit outside this shell:
/// they are focused tasks, and a tab bar there would invite a patient to
/// wander off mid-assessment.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static List<NavigationDestination> _destinations(AppLocalizations l10n) =>
      <NavigationDestination>[
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: l10n.navHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.notifications_outlined),
          selectedIcon: const Icon(Icons.notifications),
          label: l10n.navReminders,
        ),
        NavigationDestination(
          icon: const Icon(Icons.show_chart_outlined),
          selectedIcon: const Icon(Icons.show_chart),
          label: l10n.navTrends,
        ),
      ];

  void _onTap(int index) {
    // Tapping the current tab returns it to its root, which is what a patient
    // expects after opening a reminder.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: _destinations(AppLocalizations.of(context)),
        onDestinationSelected: _onTap,
      ),
    );
  }
}
