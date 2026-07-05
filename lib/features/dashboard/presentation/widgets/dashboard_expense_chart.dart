import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../data/dashboard_dummy_data.dart';

/// Weekly expense overview bar chart rendered with [CustomPainter].
///
/// Today's bar is highlighted in primary colour; past bars use a muted tonal.
/// A thin trend line traces the week's spending pattern.
class DashboardExpenseChart extends StatelessWidget {
  const DashboardExpenseChart({
    required this.points,
    super.key,
  });

  final List<ExpenseChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.28 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expense Overview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'This week · July 2026',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Total badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.65),
                  borderRadius:
                      const BorderRadius.all(Radius.circular(AppRadius.xxl)),
                ),
                child: Text(
                  '₹ 86,200',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Bar chart
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _BarChartPainter(
                points: points,
                colorScheme: colorScheme,
                isDark: isDark,
              ),
              size: Size.infinite,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Legend row
          _ChartLegend(colorScheme: colorScheme, theme: theme),
        ],
      ),
    );
  }
}

// ─── Bar chart painter ────────────────────────────────────────────────────────

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter({
    required this.points,
    required this.colorScheme,
    required this.isDark,
  });

  final List<ExpenseChartPoint> points;
  final ColorScheme colorScheme;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxAmount = points.map((p) => p.amount).reduce(math.max);
    if (maxAmount == 0) return;

    final barCount = points.length;
    final totalSpacing = size.width * 0.10;
    final totalBarWidth = size.width - totalSpacing;
    final barWidth = totalBarWidth / barCount * 0.55;
    final gap = totalBarWidth / barCount;

    final gridPaint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    // Horizontal grid lines (3 levels)
    for (var i = 1; i <= 3; i++) {
      final y = size.height * (1 - i / 3.5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Bars
    for (var i = 0; i < barCount; i++) {
      final point = points[i];
      final x = gap * i + (gap - barWidth) / 2;
      final barHeight =
          point.amount > 0 ? (point.amount / maxAmount) * size.height * 0.88 : 0.0;
      final top = size.height - barHeight;

      if (point.isToday) {
        // Today: gradient primary bar
        final rect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x, top, barWidth, barHeight),
          topLeft: const Radius.circular(AppRadius.sm),
          topRight: const Radius.circular(AppRadius.sm),
        );
        final gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.7),
          ],
        );
        canvas.drawRRect(
          rect,
          Paint()
            ..shader = gradient.createShader(
              Rect.fromLTWH(x, top, barWidth, barHeight),
            ),
        );

        // Glow
        canvas.drawRRect(
          rect,
          Paint()
            ..color = colorScheme.primary.withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6),
        );

        // Top cap dot
        canvas.drawCircle(
          Offset(x + barWidth / 2, top - 5),
          4,
          Paint()..color = colorScheme.primary,
        );
        canvas.drawCircle(
          Offset(x + barWidth / 2, top - 5),
          4,
          Paint()
            ..color = colorScheme.surface
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      } else if (point.amount > 0) {
        // Past days: muted tonal bar
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x, top, barWidth, barHeight),
            topLeft: const Radius.circular(AppRadius.sm),
            topRight: const Radius.circular(AppRadius.sm),
          ),
          Paint()
            ..color = colorScheme.secondaryContainer.withValues(alpha: 0.7),
        );
      }

      // Day label (rendered below chart — we use a Row of Texts outside)
    }

    // Trend line through bar tops
    final linePaint = Paint()
      ..color = AppColors.cautionAmber.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    bool started = false;
    for (var i = 0; i < barCount; i++) {
      final point = points[i];
      if (point.amount == 0) continue;
      final x = gap * i + gap / 2;
      final y = size.height - (point.amount / maxAmount) * size.height * 0.88;
      if (!started) {
        linePath.moveTo(x, y);
        started = true;
      } else {
        linePath.lineTo(x, y);
      }
    }
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.points != points || old.colorScheme != colorScheme;
}

// ─── Day labels row ───────────────────────────────────────────────────────────

/// Legend row showing day labels and today indicator.
class _ChartLegend extends StatelessWidget {
  const _ChartLegend({
    required this.colorScheme,
    required this.theme,
  });

  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) {
        final isToday = day == 'Sat';
        return Column(
          children: [
            Text(
              day,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (isToday) ...[
              const SizedBox(height: AppSpacing.xxs),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        );
      }).toList(),
    );
  }
}
