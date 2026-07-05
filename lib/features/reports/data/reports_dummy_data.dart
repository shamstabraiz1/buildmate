class ChartDataPoint {
  const ChartDataPoint({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}

class DailyReportData {
  const DailyReportData({
    required this.date,
    required this.totalLabourPresent,
    required this.totalExpense,
    required this.materialUsedValue,
    required this.topMaterialsUsed,
  });

  final DateTime date;
  final int totalLabourPresent;
  final double totalExpense;
  final double materialUsedValue;
  final List<String> topMaterialsUsed;
}

class WeeklyReportData {
  const WeeklyReportData({
    required this.weekRange,
    required this.totalExpense,
    required this.expenseDataPoints,
    required this.categoryBreakdown,
  });

  final String weekRange;
  final double totalExpense;
  final List<ChartDataPoint> expenseDataPoints;
  final Map<String, double> categoryBreakdown;
}

class MonthlyReportData {
  const MonthlyReportData({
    required this.monthYear,
    required this.totalBudgetConsumed,
    required this.totalBudget,
    required this.categoryBreakdown,
  });

  final String monthYear;
  final double totalBudgetConsumed;
  final double totalBudget;
  final Map<String, double> categoryBreakdown;
}

class ProjectReportData {
  const ProjectReportData({
    required this.projectId,
    required this.projectName,
    required this.overallProgress,
    required this.totalBudget,
    required this.totalSpent,
  });

  final String projectId;
  final String projectName;
  final double overallProgress;
  final double totalBudget;
  final double totalSpent;
}

class ReportsDummyData {
  const ReportsDummyData._();

  static final dailyReport = DailyReportData(
    date: DateTime(2026, 7, 4),
    totalLabourPresent: 45,
    totalExpense: 18450,
    materialUsedValue: 45000,
    topMaterialsUsed: ['Cement (50 Bags)', 'TMT Bars (2 Tons)', 'Sand (4 Brass)'],
  );

  static const weeklyReport = WeeklyReportData(
    weekRange: '28 Jun - 4 Jul 2026',
    totalExpense: 124500,
    expenseDataPoints: [
      ChartDataPoint(label: 'Mon', value: 12000),
      ChartDataPoint(label: 'Tue', value: 25000),
      ChartDataPoint(label: 'Wed', value: 8000),
      ChartDataPoint(label: 'Thu', value: 15500),
      ChartDataPoint(label: 'Fri', value: 42000),
      ChartDataPoint(label: 'Sat', value: 22000),
      ChartDataPoint(label: 'Sun', value: 0),
    ],
    categoryBreakdown: {
      'Labour': 45000,
      'Materials': 65000,
      'Fuel': 8500,
      'Misc': 6000,
    },
  );

  static const monthlyReport = MonthlyReportData(
    monthYear: 'July 2026',
    totalBudgetConsumed: 540000,
    totalBudget: 1200000,
    categoryBreakdown: {
      'Labour': 210000,
      'Materials': 280000,
      'Equipment': 35000,
      'Permits': 15000,
    },
  );

  static const projectReports = [
    ProjectReportData(
      projectId: 'p1',
      projectName: 'Skyline Tower',
      overallProgress: 0.75,
      totalBudget: 25000000,
      totalSpent: 18500000,
    ),
    ProjectReportData(
      projectId: 'p2',
      projectName: 'Green Valley Residency',
      overallProgress: 0.40,
      totalBudget: 15000000,
      totalSpent: 6200000,
    ),
    ProjectReportData(
      projectId: 'p3',
      projectName: 'Highway Overpass Z2',
      overallProgress: 0.90,
      totalBudget: 45000000,
      totalSpent: 42000000,
    ),
  ];
}
