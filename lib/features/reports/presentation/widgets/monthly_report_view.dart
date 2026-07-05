import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/reports_dummy_data.dart';

class MonthlyReportView extends StatelessWidget {
  const MonthlyReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ReportsDummyData.monthlyReport;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final progress = data.totalBudget > 0 ? (data.totalBudgetConsumed / data.totalBudget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = progress > 0.9;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            data.monthYear,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surface,
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
            ),
            child: Column(
              children: [
                Text(
                  'Budget Consumption',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 160,
                      width: 160,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 16,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: isOverBudget ? AppColors.dangerRed : colorScheme.primary,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isOverBudget ? AppColors.dangerRed : colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Consumed',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Spent', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                        Text('₹ ${_compactValue(data.totalBudgetConsumed)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total Budget', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                        Text('₹ ${_compactValue(data.totalBudget)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'Expense Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          ...data.categoryBreakdown.entries.map((entry) {
            final percentage = entry.value / data.totalBudgetConsumed;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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
              '₹ ${_compactValue(value)}',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xs)),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.safetyOrange),
          ),
        ),
      ],
    );
  }

  String _compactValue(double val) {
    if (val >= 100000) {
      return '${(val / 100000).toStringAsFixed(2)}L';
    } else if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(1)}k';
    }
    return val.toStringAsFixed(0);
  }
}
