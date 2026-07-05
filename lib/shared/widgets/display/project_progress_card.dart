import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Project overview card with budget/progress context.
class ProjectProgressCard extends StatelessWidget {
  const ProjectProgressCard({
    required this.projectName,
    required this.progress,
    this.subtitle,
    this.spentLabel,
    this.budgetLabel,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String projectName;
  final double progress;
  final String? subtitle;
  final String? spentLabel;
  final String? budgetLabel;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final normalizedProgress = progress.clamp(0.0, 1.0);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(projectName, style: textTheme.titleMedium),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle!,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    trailing!,
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              LinearProgressIndicator(value: normalizedProgress),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      spentLabel ?? '${(normalizedProgress * 100).round()}%',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (budgetLabel != null)
                    Text(
                      budgetLabel!,
                      style: textTheme.bodySmall?.copyWith(
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
}
