import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../data/dashboard_dummy_data.dart';

/// 2×2 grid of quick-action tiles for the dashboard.
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({
    required this.actions,
    required this.onActionTap,
    super.key,
  });

  final List<QuickActionData> actions;

  /// Called with the action index (0–3) when tapped.
  final ValueChanged<int> onActionTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.65,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => _QuickActionTile(
        data: actions[index],
        index: index,
        onTap: () => onActionTap(index),
      ),
    );
  }
}

// ─── Individual tile ──────────────────────────────────────────────────────────

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.data,
    required this.index,
    required this.onTap,
  });

  final QuickActionData data;
  final int index;
  final VoidCallback onTap;

  /// Each tile gets a distinct accent colour cycle.
  static const _accentPairs = [
    (AppColors.safetyOrange, AppColors.safetyOrangeLight),
    (AppColors.steelBlue, AppColors.steelBlueLight),
    (AppColors.cautionAmber, Color(0xFFFFF3CC)),
    (AppColors.successGreen, Color(0xFFD6EFDF)),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;
    final accent = _accentPairs[index % _accentPairs.length];
    final accentColor = accent.$1;
    final accentBg = isDark
        ? accentColor.withValues(alpha: 0.15)
        : accent.$2.withValues(alpha: 0.55);
    final iconBg = isDark
        ? accentColor.withValues(alpha: 0.22)
        : accentColor.withValues(alpha: 0.12);

    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: accentBg,
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.25 : 0.18),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.md),
                  ),
                ),
                child: Icon(data.icon, size: 20, color: accentColor),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Label + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      data.subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
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
