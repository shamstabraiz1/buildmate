import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../data/models/material_transaction_model.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    required this.transaction,
    required this.unit,
    this.vendorName,
    this.onDelete,
    super.key,
  });

  final MaterialTransactionModel transaction;
  final String unit;
  final String? vendorName;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final color = _typeColor(transaction.type);
    final icon = _typeIcon(transaction.type);
    final label = MaterialTransactionModel.typeLabels[transaction.type] ?? '';
    final isIncoming = transaction.increasesStock;
    final sign = isIncoming ? '+' : '−';
    final qty = transaction.quantity;
    final formattedQty = qty % 1 == 0
        ? qty.toStringAsFixed(0)
        : qty.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // Type Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppRadius.sm),
                        ),
                      ),
                      child: Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    if (vendorName != null) ...[
                      Icon(
                        Icons.storefront_outlined,
                        size: 11,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          vendorName!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                if (transaction.notes != null && transaction.notes!.isNotEmpty)
                  Text(
                    transaction.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 2),
                Text(
                  AppFormatters.date(transaction.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Quantity & price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign$formattedQty $unit',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (transaction.unitPrice != null)
                Text(
                  AppFormatters.currency(transaction.unitPrice!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
            ],
          ),

          // Delete
          if (onDelete != null) ...[
            const SizedBox(width: AppSpacing.xs),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  size: 18, color: cs.error),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: 'Delete',
            ),
          ],
        ],
      ),
    );
  }

  Color _typeColor(TransactionType type) {
    switch (type) {
      case TransactionType.purchased:
        return AppColors.successGreen;
      case TransactionType.returned:
        return AppColors.steelBlue;
      case TransactionType.used:
        return AppColors.safetyOrange;
      case TransactionType.damaged:
        return AppColors.dangerRed;
      case TransactionType.adjustment:
        return AppColors.cautionAmber;
    }
  }

  IconData _typeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.purchased:
        return Icons.add_shopping_cart_rounded;
      case TransactionType.returned:
        return Icons.keyboard_return_rounded;
      case TransactionType.used:
        return Icons.arrow_upward_rounded;
      case TransactionType.damaged:
        return Icons.broken_image_outlined;
      case TransactionType.adjustment:
        return Icons.tune_rounded;
    }
  }
}
