import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// A premium greeting header displayed at the top of the BuildMate dashboard.
///
/// Shows a time-aware greeting, the user's name, today's date, a notification
/// bell with a badge, and an avatar with gradient initials.
class DashboardGreetingHeader extends StatelessWidget {
  const DashboardGreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Left: Greeting, name, date ──────────────────────────────
            const Expanded(child: _GreetingColumn()),

            const SizedBox(width: AppSpacing.md),

            // ── Right: Notification bell + Avatar ───────────────────────
            const _NotificationBell(),
            const SizedBox(width: AppSpacing.sm),
            const _UserAvatar(),
          ],
        ),
      ),
    );
  }
}

// ─── Greeting column ─────────────────────────────────────────────────────────

class _GreetingColumn extends StatelessWidget {
  const _GreetingColumn();

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning 👋';
    if (hour >= 12 && hour < 17) return 'Good Afternoon 👋';
    if (hour >= 17 && hour < 21) return 'Good Evening 👋';
    return 'Good Night 🌙';
  }

  /// Returns a manually formatted date string, e.g. 'Friday, 4 July 2026'.
  String _formattedDate() {
    final now = DateTime.now();

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    // DateTime.weekday: 1 = Monday … 7 = Sunday
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];

    return '$weekday, ${now.day} $month ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Greeting label
        Text(
          _greeting(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: AppSpacing.xxs),

        // User name
        Text(
          'John Doe',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            height: 1.2,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // Today's date
        Text(
          _formattedDate(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─── Notification bell with badge ────────────────────────────────────────────

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bell button
          Material(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () {},
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.notifications_outlined,
                  size: 22,
                ),
              ),
            ),
          ),

          // Red dot badge
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.dangerRed,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── User avatar ─────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.safetyOrange, AppColors.steelBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.safetyOrange.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'JD',
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
