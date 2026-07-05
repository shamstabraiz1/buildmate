import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/reports_dummy_data.dart';

class ProjectReportView extends StatefulWidget {
  const ProjectReportView({super.key});

  @override
  State<ProjectReportView> createState() => _ProjectReportViewState();
}

class _ProjectReportViewState extends State<ProjectReportView> {
  ProjectReportData _selectedProject = ReportsDummyData.projectReports.first;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final data = _selectedProject;
    final financialProgress = data.totalBudget > 0 ? (data.totalSpent / data.totalBudget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = financialProgress > 0.95;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<ProjectReportData>(
            initialValue: _selectedProject,
            decoration: const InputDecoration(
              labelText: 'Select Project',
              prefixIcon: Icon(Icons.business_center_outlined),
            ),
            items: ReportsDummyData.projectReports.map((proj) {
              return DropdownMenuItem(
                value: proj,
                child: Text(proj.projectName),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedProject = v);
              }
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context: context,
                  title: 'Overall Progress',
                  value: '${(data.overallProgress * 100).toStringAsFixed(0)}%',
                  progress: data.overallProgress,
                  icon: Icons.trending_up_rounded,
                  color: AppColors.successGreen,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildMetricCard(
                  context: context,
                  title: 'Financial Progress',
                  value: '${(financialProgress * 100).toStringAsFixed(0)}%',
                  progress: financialProgress,
                  icon: Icons.account_balance_wallet_outlined,
                  color: isOverBudget ? AppColors.dangerRed : colorScheme.primary,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'Financial Summary',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surface,
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
            ),
            child: Column(
              children: [
                _buildSummaryRow(context, 'Total Budget', '₹ ${_compactValue(data.totalBudget)}', colorScheme.onSurface),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Divider(),
                ),
                _buildSummaryRow(context, 'Total Spent', '₹ ${_compactValue(data.totalSpent)}', AppColors.dangerRed),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Divider(),
                ),
                _buildSummaryRow(
                  context, 
                  'Remaining Budget', 
                  '₹ ${_compactValue(data.totalBudget - data.totalSpent)}', 
                  (data.totalBudget - data.totalSpent) < 0 ? AppColors.dangerRed : AppColors.successGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required double progress,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xs)),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _compactValue(double val) {
    final absVal = val.abs();
    if (absVal >= 100000) {
      return '${val < 0 ? '-' : ''}${(absVal / 100000).toStringAsFixed(2)}L';
    } else if (absVal >= 1000) {
      return '${val < 0 ? '-' : ''}${(absVal / 1000).toStringAsFixed(1)}k';
    }
    return val.toStringAsFixed(0);
  }
}
