import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buildmate_widgets.dart';
import 'onboarding_page_indicator.dart';

/// The persistent bottom action bar on the onboarding screen.
///
/// Renders:
/// - A [Skip] text button (hidden on the last page).
/// - A smooth [OnboardingPageIndicator].
/// - A [Next] filled button (becomes [Get Started] on the last page).
class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    required this.page,
    required this.pageCount,
    required this.onSkip,
    required this.onNext,
    required this.onGetStarted,
    super.key,
  });

  /// Fractional current page position (drives the indicator).
  final double page;

  /// Total number of pages.
  final int pageCount;

  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  bool get _isLastPage => page.round() == pageCount - 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Row(
          children: [
            // Skip button (hidden on last page with a fade)
            AnimatedOpacity(
              opacity: _isLastPage ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: _isLastPage,
                child: _SkipButton(onSkip: onSkip),
              ),
            ),

            const Spacer(),

            // Page indicator
            OnboardingPageIndicator(
              page: page,
              pageCount: pageCount,
            ),

            const Spacer(),

            // Next / Get Started button
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: _isLastPage
                  ? _GetStartedButton(
                      key: const ValueKey('get_started'),
                      onPressed: onGetStarted,
                    )
                  : _NextButton(
                      key: const ValueKey('next'),
                      onPressed: onNext,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skip button ─────────────────────────────────────────────────────────────

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onSkip,
      style: TextButton.styleFrom(
        minimumSize: const Size(64, AppSpacing.controlHeight),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.buttonBorder,
        ),
      ),
      child: const Text('Skip'),
    );
  }
}

// ─── Next button ─────────────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
      label: const Text('Next'),
      style: FilledButton.styleFrom(
        minimumSize: const Size(100, AppSpacing.controlHeight),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.buttonBorder,
        ),
      ),
    );
  }
}

// ─── Get Started button ──────────────────────────────────────────────────────

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      label: 'Get Started',
      onPressed: onPressed,
      icon: const Icon(Icons.rocket_launch_rounded, size: 18),
      isExpanded: false,
      tooltip: 'Begin using BuildMate',
    );
  }
}
