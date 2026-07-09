import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/material_model.dart';

/// A horizontal row of 3 stat cards: Purchased / Used / Remaining.
/// Pass [highlightRemaining] = true to apply low-stock warning colours.
class MaterialStatsRow extends StatelessWidget {
  const MaterialStatsRow({
    required this.material,
    this.compact = false,
    super.key,
  });

  final MaterialModel material;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Purchased',
            value:
                '${_fmt(material.quantityPurchased)} ${material.unit}',
            icon: Icons.add_shopping_cart_rounded,
            color: cs.primary,
            compact: compact,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: 'Used',
            value: '${_fmt(material.quantityUsed)} ${material.unit}',
            icon: Icons.arrow_upward_rounded,
            color: AppColors.cautionAmber,
            compact: compact,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: 'Remaining',
            value:
                '${_fmt(material.quantityRemaining)} ${material.unit}',
            icon: Icons.inventory_2_outlined,
            color: material.isOutOfStock
                ? AppColors.dangerRed
                : material.isLowStock
                    ? AppColors.cautionAmber
                    : AppColors.successGreen,
            compact: compact,
          ),
        ),
      ],
    );
  }

  String _fmt(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.compact,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest.withValues(alpha: 0.3)
            : cs.surface,
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: AppSpacing.xxs),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? AppSpacing.xxs : AppSpacing.xs),
          Text(
            value,
            style: (compact
                    ? theme.textTheme.bodySmall
                    : theme.textTheme.titleSmall)
                ?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
