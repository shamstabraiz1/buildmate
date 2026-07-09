import 'package:flutter/material.dart';

// ─── Summary card data ──────────────────────────────────────────────────────
class DashboardSummaryData {
  const DashboardSummaryData({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.trend,
    required this.trendUp,
  });
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final String trend; // e.g. '+3 this week'
  final bool trendUp;
}

// ─── Activity data ──────────────────────────────────────────────────────────
class DashboardActivityItem {
  const DashboardActivityItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.type,
    required this.timeAgo,
  });
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final ActivityType type;
  final String timeAgo;
}

enum ActivityType { expense, labour, material, report }

// ─── Project data ───────────────────────────────────────────────────────────
class DashboardProjectItem {
  const DashboardProjectItem({
    required this.name,
    required this.progress,
    required this.spent,
    required this.budget,
    required this.status,
    required this.daysLeft,
  });
  final String name;
  final double progress;
  final String spent;
  final String budget;
  final ProjectStatus status;
  final int daysLeft;
}

enum ProjectStatus { active, onHold, completed }

// ─── Expense chart data ─────────────────────────────────────────────────────
class ExpenseChartPoint {
  const ExpenseChartPoint({
    required this.label,
    required this.amount,
    required this.isToday,
  });
  final String label;
  final double amount;
  final bool isToday;
}

// ─── Quick action data ──────────────────────────────────────────────────────
class QuickActionData {
  const QuickActionData({
    required this.label,
    required this.icon,
    required this.subtitle,
  });
  final String label;
  final IconData icon;
  final String subtitle;
}

// ─── Dummy data constants ───────────────────────────────────────────────────
class DashboardDummyData {
  const DashboardDummyData._();

  static const summaryCards = [
    DashboardSummaryData(
      label: 'Active Projects',
      value: '7',
      subtitle: '3 due this month',
      icon: Icons.folder_open_rounded,
      trend: '+2 this week',
      trendUp: true,
    ),
    DashboardSummaryData(
      label: "Today's Expense",
      value: '₹ 18,400',
      subtitle: 'As of today',
      icon: Icons.receipt_long_rounded,
      trend: '+12% vs yesterday',
      trendUp: false,
    ),
    DashboardSummaryData(
      label: 'Monthly Expense',
      value: '₹ 3.2L',
      subtitle: 'July 2026',
      icon: Icons.account_balance_wallet_rounded,
      trend: '68% of budget',
      trendUp: true,
    ),
    DashboardSummaryData(
      label: 'Labour Present',
      value: '42 / 56',
      subtitle: 'Present today',
      icon: Icons.people_alt_rounded,
      trend: '75% attendance',
      trendUp: true,
    ),
  ];

  static const quickActions = [
    QuickActionData(
      label: 'Add Expense',
      icon: Icons.add_circle_outline_rounded,
      subtitle: 'Log cost',
    ),
    QuickActionData(
      label: 'Payments',
      icon: Icons.payments_rounded,
      subtitle: 'Manage payments',
    ),
    QuickActionData(
      label: 'Add Material',
      icon: Icons.inventory_2_rounded,
      subtitle: 'Track stock',
    ),
    QuickActionData(
      label: 'View Reports',
      icon: Icons.bar_chart_rounded,
      subtitle: 'Analytics',
    ),
  ];

  static const activities = [
    DashboardActivityItem(
      title: 'Cement Purchase',
      subtitle: 'Skyline Tower – Site A',
      amount: '₹ 24,500',
      icon: Icons.inventory_2_rounded,
      type: ActivityType.material,
      timeAgo: '10 min ago',
    ),
    DashboardActivityItem(
      title: 'Labour Payment',
      subtitle: 'Rajan & crew – 8 workers',
      amount: '₹ 9,600',
      icon: Icons.payments_rounded,
      type: ActivityType.labour,
      timeAgo: '1 hr ago',
    ),
    DashboardActivityItem(
      title: 'Electrical Work',
      subtitle: 'Green Valley Residency',
      amount: '₹ 6,200',
      icon: Icons.electrical_services_rounded,
      type: ActivityType.expense,
      timeAgo: '3 hrs ago',
    ),
    DashboardActivityItem(
      title: 'Sand & Gravel',
      subtitle: 'Highway Overpass – Zone 2',
      amount: '₹ 11,800',
      icon: Icons.terrain_rounded,
      type: ActivityType.material,
      timeAgo: 'Yesterday',
    ),
    DashboardActivityItem(
      title: 'Monthly Report',
      subtitle: 'Skyline Tower – June',
      amount: '',
      icon: Icons.description_rounded,
      type: ActivityType.report,
      timeAgo: 'Yesterday',
    ),
    DashboardActivityItem(
      title: 'Steel Rods',
      subtitle: 'City Mall Extension',
      amount: '₹ 38,000',
      icon: Icons.hardware_rounded,
      type: ActivityType.material,
      timeAgo: '2 days ago',
    ),
  ];

  static const projects = [
    DashboardProjectItem(
      name: 'Skyline Tower',
      progress: 0.72,
      spent: '₹ 18.4L',
      budget: '₹ 25.6L',
      status: ProjectStatus.active,
      daysLeft: 45,
    ),
    DashboardProjectItem(
      name: 'Green Valley Residency',
      progress: 0.38,
      spent: '₹ 6.2L',
      budget: '₹ 16.4L',
      status: ProjectStatus.active,
      daysLeft: 120,
    ),
    DashboardProjectItem(
      name: 'Highway Overpass Z2',
      progress: 0.91,
      spent: '₹ 42.1L',
      budget: '₹ 46.3L',
      status: ProjectStatus.active,
      daysLeft: 12,
    ),
    DashboardProjectItem(
      name: 'City Mall Extension',
      progress: 0.15,
      spent: '₹ 3.8L',
      budget: '₹ 25.0L',
      status: ProjectStatus.onHold,
      daysLeft: 180,
    ),
  ];

  static const expenseChart = [
    ExpenseChartPoint(label: 'Mon', amount: 12400, isToday: false),
    ExpenseChartPoint(label: 'Tue', amount: 8900, isToday: false),
    ExpenseChartPoint(label: 'Wed', amount: 21500, isToday: false),
    ExpenseChartPoint(label: 'Thu', amount: 15800, isToday: false),
    ExpenseChartPoint(label: 'Fri', amount: 9200, isToday: false),
    ExpenseChartPoint(label: 'Sat', amount: 18400, isToday: true),
    ExpenseChartPoint(label: 'Sun', amount: 0, isToday: false),
  ];
}
