import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

/// A reusable, theme-aware illustration placeholder for onboarding pages.
///
/// Each [pageIndex] renders a distinct construction-themed graphic using
/// [CustomPainter] so no image assets are required.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({required this.pageIndex, super.key});

  /// 0 = Manage Projects  |  1 = Track Labour & Materials  |  2 = Smart Reports
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: _semanticsLabel,
      child: AspectRatio(
        aspectRatio: 1.1,
        child: CustomPaint(
          painter: _OnboardingPainter(
            colorScheme: colorScheme,
            pageIndex: pageIndex,
          ),
          child: Center(
            child: _CenterIcon(
              icon: _centerIcon,
              colorScheme: colorScheme,
            ),
          ),
        ),
      ),
    );
  }

  String get _semanticsLabel => switch (pageIndex) {
    0 => 'Construction project management illustration',
    1 => 'Labour and materials tracking illustration',
    _ => 'Reports and analytics illustration',
  };

  IconData get _centerIcon => switch (pageIndex) {
    0 => Icons.apartment_rounded,
    1 => Icons.people_alt_rounded,
    _ => Icons.bar_chart_rounded,
  };
}

// ─── Center icon ─────────────────────────────────────────────────────────────

class _CenterIcon extends StatelessWidget {
  const _CenterIcon({required this.icon, required this.colorScheme});

  final IconData icon;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: AppRadius.dialogBorder,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 36),
    );
  }
}

// ─── Painter dispatcher ───────────────────────────────────────────────────────

class _OnboardingPainter extends CustomPainter {
  const _OnboardingPainter({
    required this.colorScheme,
    required this.pageIndex,
  });

  final ColorScheme colorScheme;
  final int pageIndex;

  @override
  void paint(Canvas canvas, Size size) {
    switch (pageIndex) {
      case 0:
        _paintProjectManagement(canvas, size);
      case 1:
        _paintLabourMaterials(canvas, size);
      default:
        _paintReportsAnalytics(canvas, size);
    }
  }

  // ── Page 0: Manage Construction Projects ─────────────────────────────────

  void _paintProjectManagement(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = colorScheme.primaryContainer.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final structurePaint = Paint()
      ..color = colorScheme.surfaceContainerHighest
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = colorScheme.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final primaryPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final secondaryPaint = Paint()
      ..color = colorScheme.secondaryContainer
      ..style = PaintingStyle.fill;
    final accentPaint = Paint()
      ..color = AppColors.cautionAmber.withValues(alpha: 0.7)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final beamPaint = Paint()
      ..color = colorScheme.secondary.withValues(alpha: 0.5)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    // Background circle
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.42,
      bgPaint,
    );

    // Main building body
    final buildingRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.28,
        size.width * 0.64,
        size.height * 0.52,
      ),
      const Radius.circular(AppRadius.lg),
    );
    canvas.drawRRect(buildingRect, structurePaint);
    canvas.drawRRect(buildingRect, outlinePaint);

    // Windows grid  (3 columns × 3 rows)
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 3; col++) {
        final wx = size.width * (0.27 + col * 0.18);
        final wy = size.height * (0.37 + row * 0.14);
        final windowRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(wx, wy, size.width * 0.1, size.height * 0.08),
          const Radius.circular(2),
        );
        canvas.drawRRect(
          windowRect,
          Paint()
            ..color = (row + col).isEven
                ? colorScheme.primary.withValues(alpha: 0.25)
                : colorScheme.secondaryContainer.withValues(alpha: 0.5)
            ..style = PaintingStyle.fill,
        );
        canvas.drawRRect(windowRect, outlinePaint..strokeWidth = 0.8);
      }
    }

    // Crane boom (horizontal)
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.18),
      Offset(size.width * 0.72, size.height * 0.18),
      primaryPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    // Crane mast (vertical)
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.18),
      Offset(size.width * 0.18, size.height * 0.78),
      primaryPaint..strokeWidth = 7,
    );

    // Crane hook cable
    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.18),
      Offset(size.width * 0.58, size.height * 0.32),
      Paint()
        ..color = colorScheme.outline
        ..strokeWidth = 2,
    );

    // Ground line
    canvas.drawLine(
      Offset(size.width * 0.10, size.height * 0.82),
      Offset(size.width * 0.90, size.height * 0.82),
      accentPaint,
    );

    // Scaffolding beams
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * (0.27 + i * 0.18), size.height * 0.28),
        Offset(size.width * (0.27 + i * 0.18), size.height * 0.82),
        beamPaint,
      );
    }

    // Roof accent bar
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.26,
        size.width * 0.64,
        size.height * 0.03,
      ),
      secondaryPaint,
    );
  }

  // ── Page 1: Track Labour & Materials ────────────────────────────────────

  void _paintLabourMaterials(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = colorScheme.secondaryContainer.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final cardPaint = Paint()
      ..color = colorScheme.surface
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = colorScheme.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final primaryBar = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final secondaryBar = Paint()
      ..color = colorScheme.secondary.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final tertiaryBar = Paint()
      ..color = colorScheme.tertiary.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    final dotPaint = Paint()..style = PaintingStyle.fill;

    // Background circle
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.43,
      bgPaint,
    );

    // Main clipboard / card
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.16,
        size.height * 0.15,
        size.width * 0.68,
        size.height * 0.65,
      ),
      const Radius.circular(AppRadius.xl),
    );
    canvas.drawRRect(cardRect, cardPaint);
    canvas.drawRRect(cardRect, outlinePaint);

    // Clipboard header bar
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
          size.width * 0.16,
          size.height * 0.15,
          size.width * 0.68,
          size.height * 0.10,
        ),
        topLeft: const Radius.circular(AppRadius.xl),
        topRight: const Radius.circular(AppRadius.xl),
      ),
      primaryBar,
    );

    // Header clip tab
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.42,
          size.height * 0.11,
          size.width * 0.16,
          size.height * 0.07,
        ),
        const Radius.circular(4),
      ),
      Paint()
        ..color = colorScheme.primaryContainer
        ..style = PaintingStyle.fill,
    );

    // Row items (labour entries)
    final rowData = [
      (primaryBar, 0.72),
      (secondaryBar, 0.55),
      (tertiaryBar, 0.82),
      (secondaryBar, 0.45),
    ];
    for (var i = 0; i < rowData.length; i++) {
      final (paint, widthFraction) = rowData[i];
      final y = size.height * (0.32 + i * 0.11);
      // Avatar dot
      dotPaint.color = paint.color.withValues(alpha: 0.8);
      canvas.drawCircle(Offset(size.width * 0.24, y + 6), 6, dotPaint);

      // Progress bar background
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.34, y + 1, size.width * 0.42, 10),
          const Radius.circular(5),
        ),
        Paint()
          ..color = colorScheme.surfaceContainerHighest
          ..style = PaintingStyle.fill,
      );
      // Progress bar fill
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.34,
            y + 1,
            size.width * 0.42 * widthFraction,
            10,
          ),
          const Radius.circular(5),
        ),
        paint,
      );

      // Separator line
      if (i < rowData.length - 1) {
        canvas.drawLine(
          Offset(size.width * 0.20, size.height * (0.32 + (i + 1) * 0.11) - 4),
          Offset(size.width * 0.80, size.height * (0.32 + (i + 1) * 0.11) - 4),
          outlinePaint,
        );
      }
    }

    // Bottom summary chips
    final chipColors = [
      colorScheme.primary.withValues(alpha: 0.15),
      colorScheme.secondary.withValues(alpha: 0.15),
      colorScheme.tertiary.withValues(alpha: 0.15),
    ];
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * (0.19 + i * 0.22),
            size.height * 0.74,
            size.width * 0.18,
            size.height * 0.04,
          ),
          const Radius.circular(8),
        ),
        Paint()
          ..color = chipColors[i]
          ..style = PaintingStyle.fill,
      );
    }
  }

  // ── Page 2: Smart Reports & Analytics ───────────────────────────────────

  void _paintReportsAnalytics(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = colorScheme.tertiaryContainer.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final cardPaint = Paint()
      ..color = colorScheme.surface
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = colorScheme.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Background circle
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.43,
      bgPaint,
    );

    // Card background
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.14,
        size.width * 0.76,
        size.height * 0.68,
      ),
      const Radius.circular(AppRadius.xl),
    );
    canvas.drawRRect(cardRect, cardPaint);
    canvas.drawRRect(cardRect, outlinePaint);

    // Bar chart — 5 bars
    final barHeights = [0.28, 0.50, 0.38, 0.65, 0.45];
    final barColors = [
      colorScheme.secondary.withValues(alpha: 0.55),
      colorScheme.primary.withValues(alpha: 0.85),
      colorScheme.secondary.withValues(alpha: 0.55),
      colorScheme.primary.withValues(alpha: 0.85),
      colorScheme.tertiary.withValues(alpha: 0.65),
    ];
    final barWidth = size.width * 0.09;
    final chartBottom = size.height * 0.70;
    final chartMaxHeight = size.height * 0.38;
    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.20 + i * 0.145);
      final barH = chartMaxHeight * barHeights[i];
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, chartBottom - barH, barWidth, barH),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        Paint()
          ..color = barColors[i]
          ..style = PaintingStyle.fill,
      );
    }

    // X axis baseline
    canvas.drawLine(
      Offset(size.width * 0.17, chartBottom),
      Offset(size.width * 0.83, chartBottom),
      outlinePaint,
    );

    // Line chart overlay (mini trend)
    final linePaint = Paint()
      ..color = AppColors.cautionAmber.withValues(alpha: 0.9)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final linePoints = [
      Offset(size.width * 0.22, chartBottom - chartMaxHeight * 0.32),
      Offset(size.width * 0.36, chartBottom - chartMaxHeight * 0.54),
      Offset(size.width * 0.50, chartBottom - chartMaxHeight * 0.40),
      Offset(size.width * 0.65, chartBottom - chartMaxHeight * 0.70),
      Offset(size.width * 0.79, chartBottom - chartMaxHeight * 0.50),
    ];
    final linePath = Path()..moveTo(linePoints[0].dx, linePoints[0].dy);
    for (final pt in linePoints.skip(1)) {
      linePath.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots on line
    for (final pt in linePoints) {
      canvas.drawCircle(
        pt,
        4,
        Paint()
          ..color = AppColors.cautionAmber
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        pt,
        4,
        Paint()
          ..color = colorScheme.surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Donut / pie accent (top-right corner of card)
    final pieCenter = Offset(size.width * 0.76, size.height * 0.26);
    final pieRadius = size.width * 0.08;
    final pieAngles = [0.0, 1.8, 3.2, 2 * math.pi];
    final pieColors = [
      colorScheme.primary.withValues(alpha: 0.85),
      colorScheme.secondary.withValues(alpha: 0.7),
      colorScheme.tertiary.withValues(alpha: 0.65),
    ];
    for (var i = 0; i < pieColors.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: pieCenter, radius: pieRadius),
        pieAngles[i] - math.pi / 2,
        pieAngles[i + 1] - pieAngles[i],
        true,
        Paint()
          ..color = pieColors[i]
          ..style = PaintingStyle.fill,
      );
    }
    // Donut hole
    canvas.drawCircle(
      pieCenter,
      pieRadius * 0.5,
      Paint()
        ..color = colorScheme.surface
        ..style = PaintingStyle.fill,
    );

    // Header label area
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.18,
          size.height * 0.19,
          size.width * 0.35,
          size.height * 0.04,
        ),
        const Radius.circular(4),
      ),
      Paint()
        ..color = colorScheme.outlineVariant.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.18,
          size.height * 0.25,
          size.width * 0.22,
          size.height * 0.03,
        ),
        const Radius.circular(4),
      ),
      Paint()
        ..color = colorScheme.outlineVariant.withValues(alpha: 0.45)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _OnboardingPainter old) =>
      old.colorScheme != colorScheme || old.pageIndex != pageIndex;
}
