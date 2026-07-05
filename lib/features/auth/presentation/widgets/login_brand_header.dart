import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

/// Animated brand header for the Login screen.
///
/// Contains:
///  - A branded app-logo badge
///  - "Welcome Back" welcome text
///  - "BuildMate" company name
///  - A tagline
class LoginBrandHeader extends StatelessWidget {
  const LoginBrandHeader({this.centerAlign = true, super.key});

  /// When [true] (default, compact layout) everything is centred.
  /// When [false] (wide layout) content aligns to the start.
  final bool centerAlign;

  @override
  Widget build(BuildContext context) {
    final alignment =
        centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centerAlign ? TextAlign.center : TextAlign.start;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        _AppLogoBadge(centered: centerAlign),
        const SizedBox(height: 20),
        _WelcomeText(textAlign: textAlign),
        const SizedBox(height: 6),
        _CompanyName(textAlign: textAlign),
        const SizedBox(height: 10),
        _Tagline(textAlign: textAlign),
      ],
    );
  }
}

// ─── App logo badge ───────────────────────────────────────────────────────────

class _AppLogoBadge extends StatelessWidget {
  const _AppLogoBadge({required this.centered});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final badge = Semantics(
      label: 'BuildMate application logo',
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.78),
            ],
          ),
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xxl)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.32),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background construction grid dots
            Positioned(
              top: 12,
              left: 12,
              child: _GridDots(color: colorScheme.onPrimary.withValues(alpha: 0.25)),
            ),
            // Main icon
            Icon(
              Icons.construction_rounded,
              color: colorScheme.onPrimary,
              size: 38,
            ),
          ],
        ),
      ),
    );

    return centered ? Center(child: badge) : badge;
  }
}

// ─── Tiny 2×2 grid decoration inside logo ────────────────────────────────────

class _GridDots extends StatelessWidget {
  const _GridDots({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        2,
        (_) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            2,
            (_) => Container(
              width: 3,
              height: 3,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── "Welcome Back" sub-heading ───────────────────────────────────────────────

class _WelcomeText extends StatelessWidget {
  const _WelcomeText({required this.textAlign});

  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      'Welcome Back',
      textAlign: textAlign,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}

// ─── "BuildMate" company name ─────────────────────────────────────────────────

class _CompanyName extends StatelessWidget {
  const _CompanyName({required this.textAlign});

  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      'BuildMate',
      textAlign: textAlign,
      style: theme.textTheme.displaySmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.1,
      ),
    );
  }
}

// ─── Tagline ──────────────────────────────────────────────────────────────────

class _Tagline extends StatelessWidget {
  const _Tagline({required this.textAlign});

  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.cautionAmber,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Plan · Track · Deliver',
          textAlign: textAlign,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 14,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.cautionAmber,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}
