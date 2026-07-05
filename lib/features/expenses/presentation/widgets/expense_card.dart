import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/expenses_dummy_data.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    required this.expense,
    this.onTap,
    super.key,
  });

  final ExpenseModel expense;
  final VoidCallback? onTap;

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.fuel: return Icons.local_gas_station_outlined;
      case ExpenseCategory.food: return Icons.restaurant_outlined;
      case ExpenseCategory.travel: return Icons.directions_car_outlined;
      case ExpenseCategory.tools: return Icons.handyman_outlined;
      case ExpenseCategory.permits: return Icons.description_outlined;
      case ExpenseCategory.materials: return Icons.category_outlined;
      case ExpenseCategory.misc: return Icons.more_horiz_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  _getCategoryIcon(expense.category),
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            expense.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₹ ${expense.amount.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.dangerRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      ExpensesDummyData.categoryLabels[expense.category] ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: colorScheme.primary),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (expense.hasReceipt) ...[
                          Icon(Icons.receipt_long_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: AppSpacing.xxs),
                        ],
                        Text(
                          ExpensesDummyData.paymentMethodLabels[expense.paymentMethod] ?? '',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
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
}
