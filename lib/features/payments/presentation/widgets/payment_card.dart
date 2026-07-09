import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/payment_model.dart';

class PaymentCard extends StatelessWidget {
  const PaymentCard({
    required this.payment,
    required this.onTap,
    super.key,
  });

  final PaymentModel payment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: AppRadius.cardBorder,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.paymentNumber,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          PaymentModel.typeLabels[payment.paymentType] ?? 'Other',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(cs, theme),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Metric(
                    label: 'Total Amount',
                    value: payment.formattedAmount,
                    color: cs.onSurface,
                  ),
                  _Metric(
                    label: 'Paid',
                    value: payment.formattedPaidAmount,
                    color: Colors.green.shade700,
                  ),
                  _Metric(
                    label: 'Pending',
                    value: payment.formattedRemainingBalance,
                    color: payment.remainingBalance > 0 ? cs.error : cs.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Due: ${payment.formattedDueDate ?? "N/A"}',
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Icon(Icons.payment_outlined, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    PaymentModel.methodLabels[payment.paymentMethod] ?? 'Cash',
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ColorScheme cs, ThemeData theme) {
    Color bg;
    Color fg;
    String label = PaymentModel.statusLabels[payment.status] ?? 'Unknown';

    switch (payment.status) {
      case PaymentStatus.paid:
        bg = Colors.green.withValues(alpha: 0.1);
        fg = Colors.green.shade700;
        break;
      case PaymentStatus.partial:
        bg = Colors.orange.withValues(alpha: 0.1);
        fg = Colors.orange.shade800;
        break;
      case PaymentStatus.pending:
        bg = cs.errorContainer;
        fg = cs.onErrorContainer;
        break;
      case PaymentStatus.cancelled:
        bg = cs.surfaceContainerHighest;
        fg = cs.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
