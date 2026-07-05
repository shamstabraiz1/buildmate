import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../data/expenses_dummy_data.dart';

class ExpenseDetailsScreen extends StatelessWidget {
  const ExpenseDetailsScreen({required this.expenseId, super.key});

  final String expenseId;

  @override
  Widget build(BuildContext context) {
    final expense = ExpensesDummyData.expenses.cast<ExpenseModel?>().firstWhere(
          (e) => e?.id == expenseId,
          orElse: () => null,
        );

    if (expense == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Expense Not Found'),
        body: Center(
          child: EmptyStateWidget(
            icon: const Icon(Icons.error_outline_rounded),
            title: 'Expense Not Found',
            message: 'This record does not exist or has been removed.',
            actionLabel: 'Go Back',
            onActionPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Expense Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Expense',
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surface,
                    borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer,
                          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xxl)),
                        ),
                        child: Text(
                          ExpensesDummyData.categoryLabels[expense.category] ?? '',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        '₹ ${expense.amount.toStringAsFixed(0)}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.dangerRed,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        expense.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const Divider(),
                      const SizedBox(height: AppSpacing.md),
                      _buildDetailRow(
                        context,
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: '${expense.date.day}/${expense.date.month}/${expense.date.year} • ${expense.date.hour}:${expense.date.minute.toString().padLeft(2, '0')}',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildDetailRow(
                        context,
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Payment Method',
                        value: ExpensesDummyData.paymentMethodLabels[expense.paymentMethod] ?? '',
                      ),
                      if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        _buildDetailRow(
                          context,
                          icon: Icons.notes_outlined,
                          label: 'Notes',
                          value: expense.notes!,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Receipt Section
                Text(
                  'Receipt & Attachments',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (expense.hasReceipt)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
                      border: Border.all(color: colorScheme.outlineVariant),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600&auto=format&fit=crop&q=60'), // Dummy receipt image
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: AppSpacing.sm,
                          right: AppSpacing.sm,
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.fullscreen_rounded),
                            label: const Text('View Full'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surface,
                      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
                      border: Border.all(color: colorScheme.outlineVariant, style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No receipt attached to this expense.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.upload_file_rounded),
                          label: const Text('Attach Receipt'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
