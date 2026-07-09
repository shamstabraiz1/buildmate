import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/project_model.dart';
import '../providers/project_stats_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays the top-level financial summary and progress of a project.
///
/// Shows:
/// - Total Budget
/// - Amount Spent
/// - Amount Remaining
/// - Circular/Linear Progress Bar
class ProjectSummaryCard extends ConsumerWidget {
  const ProjectSummaryCard({
    required this.project,
    super.key,
  });

  final ProjectModel project;

  String _formatCurrency(double amount) {
    if (amount >= 10000000) return '₹ ${(amount / 10000000).toStringAsFixed(2)} Cr';
    if (amount >= 100000) return '₹ ${(amount / 100000).toStringAsFixed(2)} L';
    return '₹ ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;

    final statsAsync = ref.watch(projectStatsProvider(project.id));

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (stats) {
        final spent = stats.totalProjectCost;
        final remaining = project.budget - spent;
        final isOverBudget = remaining < 0;
        final progress = project.budget > 0 ? (spent / project.budget) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Financial Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                // Wide layout
                return Row(
                  children: [
                    Expanded(
                      child: _buildMetric(
                        context,
                        label: 'Total Budget',
                        value: project.formattedBudget,
                        icon: Icons.monetization_on_outlined,
                        color: colorScheme.primary,
                      ),
                    ),
                    _buildDivider(context),
                    Expanded(
                      child: _buildMetric(
                        context,
                        label: 'Amount Spent',
                        value: _formatCurrency(spent),
                        icon: Icons.receipt_long_outlined,
                        color: AppColors.cautionAmber,
                      ),
                    ),
                    _buildDivider(context),
                    Expanded(
                      child: _buildMetric(
                        context,
                        label: 'Remaining',
                        value: _formatCurrency(remaining.abs()),
                        icon: Icons.savings_outlined,
                        color: isOverBudget ? AppColors.dangerRed : AppColors.successGreen,
                        subtitle: isOverBudget ? 'Over budget' : 'Available',
                      ),
                    ),
                  ],
                );
              }

              // Compact layout
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetric(
                          context,
                          label: 'Total Budget',
                          value: project.formattedBudget,
                          icon: Icons.monetization_on_outlined,
                          color: colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: _buildMetric(
                          context,
                          label: 'Amount Spent',
                          value: _formatCurrency(spent),
                          icon: Icons.receipt_long_outlined,
                          color: AppColors.cautionAmber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildMetric(
                    context,
                    label: 'Remaining Budget',
                    value: _formatCurrency(remaining.abs()),
                    icon: Icons.savings_outlined,
                    color: isOverBudget ? AppColors.dangerRed : AppColors.successGreen,
                    subtitle: isOverBudget ? 'Over budget' : 'Available',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildProgressBar(context, colorScheme, isOverBudget, progress),
        ],
      ),
    );
      },
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, ColorScheme colorScheme, bool isOverBudget, double progressValue) {
    final progress = progressValue.clamp(0.0, 1.0);
    final barColor = isOverBudget ? AppColors.dangerRed : colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Project Completion',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: barColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xs)),
          child: Stack(
            children: [
              Container(
                height: 8,
                color: colorScheme.surfaceContainerHighest,
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        barColor.withValues(alpha: 0.6),
                        barColor,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
