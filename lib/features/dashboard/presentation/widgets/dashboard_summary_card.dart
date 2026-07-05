import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../data/dashboard_dummy_data.dart';

/// Premium summary metric card for the dashboard.
///
/// Renders a gradient accent strip, icon, value, label, and a
/// colour-coded trend badge. Adapts to light/dark themes.
class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({
    required this.data,
    this.onTap,
    super.key,
  });

  final DashboardSummaryData data;
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
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient accent strip
              _AccentStrip(isDark: isDark),

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
                    // Icon + label row
                    Row(
                      children: [
                        _CardIcon(icon: data.icon, colorScheme: colorScheme),
                        const Spacer(),
                        _TrendBadge(
                          trend: data.trend,
                          trendUp: data.trendUp,
                          colorScheme: colorScheme,
                          theme: theme,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Value
                    Text(
                      data.value,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        height: 1.0,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxs),

                    // Label
                    Text(
                      data.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxs),

                    // Subtitle
                    Text(
                      data.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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

// ─── Accent strip ─────────────────────────────────────────────────────────────

class _AccentStrip extends StatelessWidget {
  const _AccentStrip({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.safetyOrangeDark, AppColors.steelBlueDark]
              : [AppColors.safetyOrange, AppColors.steelBlue],
        ),
      ),
    );
  }
}

// ─── Card icon ────────────────────────────────────────────────────────────────

class _CardIcon extends StatelessWidget {
  const _CardIcon({required this.icon, required this.colorScheme});

  final IconData icon;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
      ),
      child: Icon(icon, size: 20, color: colorScheme.primary),
    );
  }
}

// ─── Trend badge ──────────────────────────────────────────────────────────────

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({
    required this.trend,
    required this.trendUp,
    required this.colorScheme,
    required this.theme,
  });

  final String trend;
  final bool trendUp;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final bg = trendUp
        ? AppColors.successGreen.withValues(alpha: 0.12)
        : colorScheme.errorContainer.withValues(alpha: 0.4);
    final fg = trendUp ? AppColors.successGreen : colorScheme.error;

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
          Icon(
            trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 12,
            color: fg,
          ),
          const SizedBox(width: 2),
          Text(
            trend,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
