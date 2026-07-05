import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Full-screen decorative background for the Login screen.
///
/// Renders a branded gradient with subtle construction-themed geometry
/// (grid lines and corner accents) that adapts to light and dark modes.
class LoginBackground extends StatelessWidget {
  const LoginBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _buildGradient(colorScheme),
      ),
      child: CustomPaint(
        painter: _ConstructionPatternPainter(colorScheme: colorScheme),
        child: child,
      ),
    );
  }

  LinearGradient _buildGradient(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0.0, 0.45, 1.0],
      colors: isDark
          ? [
              AppColors.blueprintNavyDark,
              colorScheme.surface,
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.50),
            ]
          : [
              colorScheme.primaryContainer.withValues(alpha: 0.30),
              colorScheme.surface,
              AppColors.lightBackground,
            ],
    );
  }
}

// ─── Subtle construction-blueprint pattern painter ────────────────────────────

class _ConstructionPatternPainter extends CustomPainter {
  const _ConstructionPatternPainter({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final lineColor = isDark
        ? colorScheme.primary.withValues(alpha: 0.06)
        : colorScheme.primary.withValues(alpha: 0.055);
    final accentColor = AppColors.cautionAmber.withValues(alpha: 0.12);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Blueprint grid — vertical lines
    const gridStep = 48.0;
    var x = 0.0;
    while (x <= size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
      x += gridStep;
    }

    // Blueprint grid — horizontal lines
    var y = 0.0;
    while (y <= size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      y += gridStep;
    }

    // Top-left corner accent — L-bracket
    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      const Offset(24, 80),
      const Offset(24, 24),
      accentPaint,
    );
    canvas.drawLine(
      const Offset(24, 24),
      const Offset(80, 24),
      accentPaint,
    );

    // Bottom-right corner accent — L-bracket
    canvas.drawLine(
      Offset(size.width - 24, size.height - 80),
      Offset(size.width - 24, size.height - 24),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width - 24, size.height - 24),
      Offset(size.width - 80, size.height - 24),
      accentPaint,
    );

    // Safety-stripe accent — diagonal lines top-right
    final stripePaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.04)
      ..strokeWidth = 6.0;

    for (var i = 0; i < 8; i++) {
      final startX = size.width - 160 + i * 22.0;
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + 80, 80),
        stripePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConstructionPatternPainter old) =>
      old.colorScheme != colorScheme;
}
