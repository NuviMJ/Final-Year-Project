import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Holds the three tabbed destinations and the bar that switches between them.
///
/// The assessment flow, history, learn and settings sit outside this shell:
/// they are focused tasks, and a tab bar there would invite a patient to
/// wander off mid-assessment.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<NavigationDestination> _destinations =
      <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications),
      label: 'Reminders',
    ),
    NavigationDestination(
      icon: Icon(Icons.show_chart_outlined),
      selectedIcon: Icon(Icons.show_chart),
      label: 'Trends',
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
        destinations: _destinations,
        onDestinationSelected: _onTap,
      ),
    );
  }
}
