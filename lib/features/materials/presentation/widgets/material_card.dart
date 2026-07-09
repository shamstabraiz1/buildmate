import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/status_chip.dart';
import '../../data/models/material_model.dart';

class MaterialCard extends StatelessWidget {
  const MaterialCard({
    required this.material,
    this.onTap,
    super.key,
  });

  final MaterialModel material;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    final isLow = material.isLowStock;
    final isOut = material.isOutOfStock;
    final alertColor =
        isOut ? AppColors.dangerRed : AppColors.cautionAmber;
    final hasAlert = isLow || isOut;

    final borderColor = hasAlert
        ? alertColor.withValues(alpha: 0.5)
        : cs.outlineVariant.withValues(alpha: 0.5);

    final topBarColor =
        isOut ? AppColors.dangerRed : isLow ? AppColors.cautionAmber : cs.primary;

    return Material(
      color: cs.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: hasAlert ? 1.5 : 1),
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coloured top stripe
              Container(height: 4, color: topBarColor),

              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header row ──────────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image or icon
                        _buildLeading(cs),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                material.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                material.materialNumber,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                material.displayCategory,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status chip
                        if (hasAlert)
                          StatusChip(
                            label: isOut ? 'Out of Stock' : 'Low Stock',
                            status: StatusChipType.danger,
                          ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ── Stock progress bar ───────────────────────────────────
                    _buildStockBar(theme, cs),

                    const SizedBox(height: AppSpacing.sm),

                    // ── Three-column stat footer ─────────────────────────────
                    Row(
                      children: [
                        _buildStat(
                          theme,
                          cs,
                          label: 'Purchased',
                          value: '${_fmt(material.quantityPurchased)} ${material.unit}',
                          color: cs.primary,
                        ),
                        _buildDivider(cs),
                        _buildStat(
                          theme,
                          cs,
                          label: 'Used',
                          value: '${_fmt(material.quantityUsed)} ${material.unit}',
                          color: AppColors.cautionAmber,
                        ),
                        _buildDivider(cs),
                        _buildStat(
                          theme,
                          cs,
                          label: 'Remaining',
                          value: '${_fmt(material.quantityRemaining)} ${material.unit}',
                          color: hasAlert ? alertColor : AppColors.successGreen,
                        ),
                      ],
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

  Widget _buildLeading(ColorScheme cs) {
    if (material.imagePath != null &&
        material.imagePath!.isNotEmpty &&
        !kIsWeb) {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
        child: Image.file(
          File(material.imagePath!),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _iconBox(cs),
        ),
      );
    }
    return _iconBox(cs);
  }

  Widget _iconBox(ColorScheme cs) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
      ),
      child: Icon(
        MaterialModel.categoryIcons[material.category] ??
            Icons.category_outlined,
        color: cs.onPrimaryContainer,
        size: 22,
      ),
    );
  }

  Widget _buildStockBar(ThemeData theme, ColorScheme cs) {
    final purchased = material.quantityPurchased;
    final used = material.quantityUsed;
    if (purchased <= 0) {
      return const SizedBox.shrink();
    }
    final usedRatio = (used / purchased).clamp(0.0, 1.0);
    final barColor = material.isOutOfStock
        ? AppColors.dangerRed
        : material.isLowStock
            ? AppColors.cautionAmber
            : AppColors.successGreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xxl)),
          child: LinearProgressIndicator(
            value: usedRatio,
            minHeight: 5,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(
    ThemeData theme,
    ColorScheme cs, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ColorScheme cs) {
    return Container(
      width: 1,
      height: 28,
      color: cs.outlineVariant.withValues(alpha: 0.4),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
    );
  }

  String _fmt(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}
