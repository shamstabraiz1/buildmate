import 'package:flutter/material.dart';

/// Enum representing the five destinations in the bottom navigation.
enum DashboardNavDestination { dashboard, projects, expenses, reports, settings }

/// Custom Material 3 bottom navigation bar for BuildMate.
///
/// Uses [NavigationBar] with a styled indicator and labelled destinations.
/// The currently selected item is [selectedDestination].
class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({
    required this.selectedDestination,
    required this.onDestinationSelected,
    super.key,
  });

  final DashboardNavDestination selectedDestination;
  final ValueChanged<DashboardNavDestination> onDestinationSelected;

  static const _destinations = [
    (
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      dest: DashboardNavDestination.dashboard,
    ),
    (
      label: 'Projects',
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
      dest: DashboardNavDestination.projects,
    ),
    (
      label: 'Expenses',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      dest: DashboardNavDestination.expenses,
    ),
    (
      label: 'Reports',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      dest: DashboardNavDestination.reports,
    ),
    (
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      dest: DashboardNavDestination.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedIndex = DashboardNavDestination.values
        .indexOf(selectedDestination);

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (i) =>
          onDestinationSelected(DashboardNavDestination.values[i]),
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: AppElevation.level2,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: _destinations
          .map(
            (d) => NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(
                d.activeIcon,
                color: colorScheme.onPrimaryContainer,
              ),
              label: d.label,
              tooltip: d.label,
            ),
          )
          .toList(),
    );
  }
}

// Re-export elevation for use within this file without extra import.
class AppElevation {
  const AppElevation._();
  static const level2 = 3.0;
}
