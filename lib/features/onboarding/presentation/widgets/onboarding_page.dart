import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import 'onboarding_illustration.dart';

/// Data class describing a single onboarding step.
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.pageIndex,
  });

  final String title;
  final String description;
  final int pageIndex;
}

/// A single full-screen onboarding page.
///
/// Adapts its layout for narrow phones (compact) and wider devices (expanded),
/// and supports both light and dark themes via the BuildMate design system.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({required this.data, super.key});

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 720;

    return isWide
        ? _WideOnboardingPage(data: data)
        : _CompactOnboardingPage(data: data);
  }
}

// ─── Compact layout (phones) ─────────────────────────────────────────────────

class _CompactOnboardingPage extends StatelessWidget {
  const _CompactOnboardingPage({required this.data});

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: _OnboardingGradient.of(context)),
      child: Column(
        children: [
          // Illustration section (flexible upper half)
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Center(
                child: _IllustrationCard(pageIndex: data.pageIndex),
              ),
            ),
          ),

          // Text section (lower portion)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: _OnboardingText(
                title: data.title,
                description: data.description,
                textAlign: TextAlign.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wide layout (tablets / desktop) ─────────────────────────────────────────

class _WideOnboardingPage extends StatelessWidget {
  const _WideOnboardingPage({required this.data});

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: _OnboardingGradient.of(context)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: Row(
              children: [
                // Text on the left
                Expanded(
                  child: _OnboardingText(
                    title: data.title,
                    description: data.description,
                    textAlign: TextAlign.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                const SizedBox(width: AppSpacing.xxxl),

                // Illustration on the right
                Expanded(
                  child: _IllustrationCard(pageIndex: data.pageIndex),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Illustration card ────────────────────────────────────────────────────────

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard({required this.pageIndex});

  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xxl)),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: OnboardingIllustration(pageIndex: pageIndex),
    );
  }
}

// ─── Text block ───────────────────────────────────────────────────────────────

class _OnboardingText extends StatelessWidget {
  const _OnboardingText({
    required this.title,
    required this.description,
    required this.textAlign,
    required this.crossAxisAlignment,
  });

  final String title;
  final String description;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Accent badge
        _PageAccentBadge(colorScheme: colorScheme, align: crossAxisAlignment),

        const SizedBox(height: AppSpacing.lg),

        // Title
        Text(
          title,
          textAlign: textAlign,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Description
        Text(
          description,
          textAlign: textAlign,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

// ─── Accent badge ─────────────────────────────────────────────────────────────

class _PageAccentBadge extends StatelessWidget {
  const _PageAccentBadge({
    required this.colorScheme,
    required this.align,
  });

  final ColorScheme colorScheme;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: align == CrossAxisAlignment.center
          ? Alignment.center
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 14,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'BuildMate',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Gradient factory ─────────────────────────────────────────────────────────

class _OnboardingGradient {
  const _OnboardingGradient._();

  static LinearGradient of(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        isDark
            ? AppColors.blueprintNavyDark
            : colorScheme.surface,
        colorScheme.surface,
        isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.40)
            : AppColors.lightBackground,
      ],
      stops: const [0.0, 0.45, 1.0],
    );
  }
}
