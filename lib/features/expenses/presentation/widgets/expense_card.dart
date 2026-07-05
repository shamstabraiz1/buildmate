import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/status_chip.dart';
import '../../data/models/expense_model.dart';

/// Full-detail expense card displayed in the expenses list.
class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    required this.expense,
    required this.projectName,
    this.onTap,
    super.key,
  });

  final ExpenseModel expense;
  final String projectName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;

    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.28 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top accent strip + status ────────────────────────────────
              _CardHeader(expense: expense),

              // ── Body ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expense category and Number
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            expense.categoryId.isEmpty ? 'Uncategorized' : expense.categoryId,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          expense.expenseNumber,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // Project name + Date row
                    _InfoRow(
                      icon: Icons.apartment_rounded,
                      text: projectName,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      text: expense.formattedDate,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Divider
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Amount + Payment Method row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                expense.formattedAmount,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Method',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                ExpenseModel.paymentMethodLabels[expense.paymentMethod] ?? 'Unknown',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (expense.vendor != null && expense.vendor!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      _InfoRow(
                        icon: Icons.storefront_outlined,
                        text: 'Vendor: ${expense.vendor}',
                      ),
                    ],
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

// ─── Card header (accent strip + icon + status chip) ─────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.expense});

  final ExpenseModel expense;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final statusColor = _statusAccentColor(expense.status, colorScheme);

    return Stack(
      children: [
        // Gradient accent background
        Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                statusColor.withValues(alpha: isDark ? 0.22 : 0.14),
                colorScheme.surface,
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Expense icon badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.md),
                  ),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 18,
                  color: statusColor,
                ),
              ),

              const Spacer(),

              // Status chip
              StatusChip(
                label: ExpenseModel.statusLabels[expense.status]!,
                status: _chipType(expense.status),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _statusAccentColor(ExpenseStatus status, ColorScheme cs) =>
      switch (status) {
        ExpenseStatus.paid          => AppColors.successGreen,
        ExpenseStatus.pending       => AppColors.dangerRed,
        ExpenseStatus.partiallyPaid => cs.tertiary,
      };

  StatusChipType _chipType(ExpenseStatus status) => switch (status) {
    ExpenseStatus.paid          => StatusChipType.success,
    ExpenseStatus.pending       => StatusChipType.danger,
    ExpenseStatus.partiallyPaid => StatusChipType.warning,
  };
}

// ─── Generic info row ─────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
