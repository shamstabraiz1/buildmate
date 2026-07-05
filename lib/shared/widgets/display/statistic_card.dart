import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Small statistic card for dashboard metrics and list headers.
class StatisticCard extends StatelessWidget {
  const StatisticCard({
    required this.label,
    required this.value,
    this.icon,
    this.caption,
    this.trend,
    super.key,
  });

  final String label;
  final String value;
  final Widget? icon;
  final String? caption;
  final Widget? trend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            if (icon != null) ...[
              IconTheme(
                data: IconThemeData(color: colorScheme.primary),
                child: icon!,
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(value, style: textTheme.titleLarge),
                  if (caption != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      caption!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trend,
          ],
        ),
      ),
    );
  }
}
