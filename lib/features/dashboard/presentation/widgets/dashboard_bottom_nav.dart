import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';

/// Enum representing the destinations in the bottom navigation.
enum DashboardNavDestination { dashboard, projects, expenses, payments, reports, settings }

/// Custom Material 3 bottom navigation bar for BuildMate.
class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({
    required this.selectedDestination,
    super.key,
  });

  final DashboardNavDestination selectedDestination;

  static const _destinations = [
    (
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      dest: DashboardNavDestination.dashboard,
      route: AppRoutes.dashboard,
    ),
    (
      label: 'Projects',
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
      dest: DashboardNavDestination.projects,
      route: AppRoutes.projects,
    ),
    (
      label: 'Expenses',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      dest: DashboardNavDestination.expenses,
      route: AppRoutes.expenses,
    ),
    (
      label: 'Payments',
      icon: Icons.payments_outlined,
      activeIcon: Icons.payments_rounded,
      dest: DashboardNavDestination.payments,
      route: AppRoutes.payments,
    ),
    (
      label: 'Reports',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      dest: DashboardNavDestination.reports,
      route: AppRoutes.reports,
    ),
    (
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      dest: DashboardNavDestination.settings,
      route: AppRoutes.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedIndex = DashboardNavDestination.values.indexOf(selectedDestination);

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (i) {
        final dest = _destinations[i];
        if (dest.dest != selectedDestination) {
          context.go(dest.route);
        }
      },
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: AppElevation.level2,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // Hide labels to fit 6 items comfortably
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
