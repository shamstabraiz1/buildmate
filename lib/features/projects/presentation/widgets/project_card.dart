import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/status_chip.dart';
import '../../data/models/project_model.dart';

/// Full-detail project card displayed in the projects list.
///
/// Contains: project name, client, location, budget, amount spent,
/// a segmented progress bar, a status badge, and the start date.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    required this.project,
    this.onTap,
    super.key,
  });

  final ProjectModel project;
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
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.28 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top accent strip + status ────────────────────────────────
              _CardHeader(project: project),

              // ── Body ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project name
                    Text(
                      project.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // Client + location row
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      text: project.clientName,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      text: project.location,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Divider
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Budget + spent row
                    _BudgetRow(project: project, theme: theme, colorScheme: colorScheme),

                    const SizedBox(height: AppSpacing.md),

                    // Progress bar + label
                    _ProgressSection(project: project, colorScheme: colorScheme, theme: theme),

                    const SizedBox(height: AppSpacing.md),

                    // Start date
                    _StartDateRow(project: project, theme: theme, colorScheme: colorScheme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Card header (accent strip + project icon + status chip) ──────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final statusColor = _statusAccentColor(project.status, colorScheme);

    return Stack(
      children: [
        // Gradient accent background
        Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                statusColor.withValues(alpha: isDark ? 0.22 : 0.14),
                colorScheme.surface,
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Project icon badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.md),
                  ),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.apartment_rounded,
                  size: 18,
                  color: statusColor,
                ),
              ),

              const Spacer(),

              // Status chip
              StatusChip(
                label: ProjectModel.statusLabels[project.status]!,
                status: _chipType(project.status),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _statusAccentColor(ProjectStatus status, ColorScheme cs) =>
      switch (status) {
        ProjectStatus.active    => cs.primary,
        ProjectStatus.onHold    => cs.tertiary,
        ProjectStatus.completed => AppColors.successGreen,
        ProjectStatus.planning  => cs.secondary,
      };

  StatusChipType _chipType(ProjectStatus status) => switch (status) {
    ProjectStatus.active    => StatusChipType.info,
    ProjectStatus.onHold    => StatusChipType.warning,
    ProjectStatus.completed => StatusChipType.success,
    ProjectStatus.planning  => StatusChipType.neutral,
  };
}

// ─── Generic info row ─────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Budget / spent row ───────────────────────────────────────────────────────

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.project,
    required this.theme,
    required this.colorScheme,
  });

  final ProjectModel project;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCell(
            label: 'Budget',
            value: project.formattedBudget,
            icon: Icons.account_balance_wallet_rounded,
            theme: theme,
            colorScheme: colorScheme,
            valueColor: colorScheme.onSurface,
          ),
        ),
        Container(
          width: 1,
          height: 36,
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: _MetricCell(
              label: 'Amount Spent',
              value: project.formattedSpent,
              icon: Icons.receipt_long_rounded,
              theme: theme,
              colorScheme: colorScheme,
              valueColor: project.progress >= 0.95
                  ? AppColors.dangerRed
                  : colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
    required this.colorScheme,
    required this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 11, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ─── Progress bar section ─────────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.project,
    required this.colorScheme,
    required this.theme,
  });

  final ProjectModel project;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isOverrun = project.progress >= 0.95;
    final barColor = switch (project.status) {
      ProjectStatus.active    =>
        isOverrun ? AppColors.dangerRed : colorScheme.primary,
      ProjectStatus.onHold    => colorScheme.tertiary,
      ProjectStatus.completed => AppColors.successGreen,
      ProjectStatus.planning  => colorScheme.secondary,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          children: [
            Text(
              'Progress',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              project.progressPercent,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: barColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xs),

        // Bar
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xs)),
          child: Stack(
            children: [
              Container(
                height: 8,
                color: colorScheme.surfaceContainerHighest,
              ),
              FractionallySizedBox(
                widthFactor: project.progress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        barColor.withValues(alpha: 0.65),
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

// ─── Start date row ───────────────────────────────────────────────────────────

class _StartDateRow extends StatelessWidget {
  const _StartDateRow({
    required this.project,
    required this.theme,
    required this.colorScheme,
  });

  final ProjectModel project;
  final ThemeData theme;
  final ColorScheme colorScheme;

  String _fmt(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_rounded,
          size: 12,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'Started ${_fmt(project.startDate)}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.flag_outlined,
          size: 12,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          'Due ${_fmt(project.endDate)}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
