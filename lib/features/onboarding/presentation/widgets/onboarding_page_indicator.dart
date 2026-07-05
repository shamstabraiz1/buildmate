import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Animated page indicator showing dots that expand/contract and blend colors
/// based on the current [page] position and [pageCount].
///
/// Place this widget in a [Row] or pass it directly — it sizes itself naturally.
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    required this.page,
    required this.pageCount,
    super.key,
  });

  /// The current fractional page position (e.g. from [PageController.page]).
  final double page;

  /// Total number of pages.
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Page ${page.round() + 1} of $pageCount',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(pageCount, (index) {
          return _IndicatorDot(
            index: index,
            page: page,
            activeColor: colorScheme.primary,
            inactiveColor: colorScheme.outlineVariant,
          );
        }),
      ),
    );
  }
}

// ─── Individual animated dot ─────────────────────────────────────────────────

class _IndicatorDot extends StatelessWidget {
  const _IndicatorDot({
    required this.index,
    required this.page,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int index;
  final double page;
  final Color activeColor;
  final Color inactiveColor;

  static const _dotHeight = 8.0;
  static const _activeDotWidth = 28.0;
  static const _inactiveDotWidth = 8.0;
  static const _gap = AppSpacing.xs;

  @override
  Widget build(BuildContext context) {
    // Distance from this dot's integer index to current fractional page.
    final distance = (page - index).abs().clamp(0.0, 1.0);
    final isActive = distance < 1.0;

    // Lerp width: fully active → _activeDotWidth, fully inactive → _inactiveDotWidth
    final width = isActive
        ? _lerpDouble(_activeDotWidth, _inactiveDotWidth, distance)
        : _inactiveDotWidth;

    // Lerp color
    final color = Color.lerp(activeColor, inactiveColor, distance)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _gap / 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: width,
        height: _dotHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(_dotHeight / 2),
          boxShadow: isActive && distance < 0.5
              ? [
                  BoxShadow(
                    color: activeColor.withValues(
                      alpha: (0.4 * (1 - distance * 2)).clamp(0.0, 0.4),
                    ),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
