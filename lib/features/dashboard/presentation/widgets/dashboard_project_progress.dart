import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/status_chip.dart';
import '../data/dashboard_dummy_data.dart';

/// Project progress list for the dashboard.
///
/// Each row shows the project name, a rich segmented progress bar,
/// spent vs. budget labels, status chip, and days-remaining badge.
class DashboardProjectProgress extends StatelessWidget {
  const DashboardProjectProgress({
    required this.projects,
    this.onProjectTap,
    super.key,
  });

  final List<DashboardProjectItem> projects;
  final ValueChanged<int>? onProjectTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(projects.length, (i) {
        final project = projects[i];
        return Padding(
          padding: EdgeInsets.only(
            bottom: i < projects.length - 1 ? AppSpacing.md : 0,
          ),
          child: _ProjectProgressTile(
            project: project,
            onTap: onProjectTap != null ? () => onProjectTap!(i) : null,
          ),
        );
      }),
    );
  }
}

// ─── Individual project tile ──────────────────────────────────────────────────

class _ProjectProgressTile extends StatelessWidget {
  const _ProjectProgressTile({
    required this.project,
    this.onTap,
  });

  final DashboardProjectItem project;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;

    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.22 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: name + chips
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _statusAccentBg(project.status, colorScheme),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppRadius.md),
                      ),
                    ),
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 18,
                      color: _statusAccentFg(project.status, colorScheme),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Row(
                          children: [
                            StatusChip(
                              label: _statusLabel(project.status),
                              status: _chipType(project.status),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _DaysLeftBadge(
                              daysLeft: project.daysLeft,
                              colorScheme: colorScheme,
                              theme: theme,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Percentage
                  Text(
                    '${(project.progress * 100).round()}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _statusAccentFg(project.status, colorScheme),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Segmented progress bar
              _SegmentedProgressBar(
                progress: project.progress,
                status: project.status,
                colorScheme: colorScheme,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Budget row
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    'Spent ${project.spent}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Budget ${project.budget}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusAccentBg(ProjectStatus status, ColorScheme cs) => switch (status) {
    ProjectStatus.active   => cs.primaryContainer.withValues(alpha: 0.65),
    ProjectStatus.onHold   => cs.tertiaryContainer.withValues(alpha: 0.6),
    ProjectStatus.completed => AppColors.successGreen.withValues(alpha: 0.12),
  };

  Color _statusAccentFg(ProjectStatus status, ColorScheme cs) => switch (status) {
    ProjectStatus.active   => cs.primary,
    ProjectStatus.onHold   => cs.tertiary,
    ProjectStatus.completed => AppColors.successGreen,
  };

  String _statusLabel(ProjectStatus status) => switch (status) {
    ProjectStatus.active    => 'Active',
    ProjectStatus.onHold    => 'On Hold',
    ProjectStatus.completed => 'Done',
  };

  StatusChipType _chipType(ProjectStatus status) => switch (status) {
    ProjectStatus.active    => StatusChipType.info,
    ProjectStatus.onHold    => StatusChipType.warning,
    ProjectStatus.completed => StatusChipType.success,
  };
}

// ─── Segmented progress bar ───────────────────────────────────────────────────

class _SegmentedProgressBar extends StatelessWidget {
  const _SegmentedProgressBar({
    required this.progress,
    required this.status,
    required this.colorScheme,
  });

  final double progress;
  final ProjectStatus status;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final filled = switch (status) {
      ProjectStatus.active   => colorScheme.primary,
      ProjectStatus.onHold   => colorScheme.tertiary,
      ProjectStatus.completed => AppColors.successGreen,
    };
    // Warn in red if overrun (>95%)
    final barColor = progress >= 0.95 ? AppColors.dangerRed : filled;

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xs)),
      child: Stack(
        children: [
          // Track
          Container(
            height: 8,
            color: colorScheme.surfaceContainerHighest,
          ),
          // Fill
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    barColor.withValues(alpha: 0.7),
                    barColor,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Days left badge ──────────────────────────────────────────────────────────

class _DaysLeftBadge extends StatelessWidget {
  const _DaysLeftBadge({
    required this.daysLeft,
    required this.colorScheme,
    required this.theme,
  });

  final int daysLeft;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isUrgent = daysLeft <= 14;
    final bg = isUrgent
        ? colorScheme.errorContainer.withValues(alpha: 0.5)
        : colorScheme.surfaceContainerHighest;
    final fg = isUrgent ? colorScheme.error : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xxl)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 10, color: fg),
          const SizedBox(width: 2),
          Text(
            '$daysLeft days',
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
