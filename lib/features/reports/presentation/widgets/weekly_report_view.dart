import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/reports_dummy_data.dart';
import 'custom_bar_chart.dart';

class WeeklyReportView extends StatelessWidget {
  const WeeklyReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ReportsDummyData.weeklyReport;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    // Find the max value for the chart to scale properly
    double maxExp = 0;
    for (var point in data.expenseDataPoints) {
      if (point.value > maxExp) maxExp = point.value;
    }
    // Give some headroom
    maxExp = maxExp * 1.2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            data.weekRange,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xxl)),
            ),
            child: Column(
              children: [
                Text(
                  'Total Weekly Expense',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '₹ ${data.totalExpense.toStringAsFixed(0)}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'Daily Expenditure',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 200,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surface,
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
            ),
            child: CustomBarChart(
              data: data.expenseDataPoints,
              maxValue: maxExp,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'Category Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          ...data.categoryBreakdown.entries.map((entry) {
            final percentage = entry.value / data.totalExpense;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildCategoryRow(
                context,
                label: entry.key,
                value: entry.value,
                percentage: percentage,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, {required String label, required double value, required double percentage}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text(
              '₹ ${value.toStringAsFixed(0)}',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xs)),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
