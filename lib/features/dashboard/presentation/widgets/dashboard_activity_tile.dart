import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../data/dashboard_dummy_data.dart';

/// A single recent-activity list tile for the dashboard.
///
/// Shows an icon, title, subtitle, amount and time ago text.
/// The icon background colour is keyed to [ActivityType].
class DashboardActivityTile extends StatelessWidget {
  const DashboardActivityTile({
    required this.item,
    this.onTap,
    super.key,
  });

  final DashboardActivityItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final colors = _activityColors(item.type, colorScheme);

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.bg,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.md),
                ),
              ),
              child: Icon(item.icon, size: 20, color: colors.fg),
            ),
            const SizedBox(width: AppSpacing.md),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Amount + time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (item.amount.isNotEmpty)
                  Text(
                    item.amount,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  item.timeAgo,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ({Color bg, Color fg}) _activityColors(
    ActivityType type,
    ColorScheme colorScheme,
  ) {
    return switch (type) {
      ActivityType.expense => (
          bg: colorScheme.errorContainer.withValues(alpha: 0.5),
          fg: colorScheme.error,
        ),
      ActivityType.labour => (
          bg: AppColors.steelBlue.withValues(alpha: 0.12),
          fg: AppColors.steelBlue,
        ),
      ActivityType.material => (
          bg: colorScheme.primaryContainer.withValues(alpha: 0.65),
          fg: colorScheme.primary,
        ),
      ActivityType.report => (
          bg: colorScheme.secondaryContainer.withValues(alpha: 0.6),
          fg: colorScheme.secondary,
        ),
    };
  }
}
