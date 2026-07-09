import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/layout/custom_scaffold.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../data/models/payment_history_model.dart';
import '../../data/models/payment_model.dart';
import '../providers/payment_providers.dart';

class PaymentDetailsScreen extends ConsumerWidget {
  const PaymentDetailsScreen({
    required this.paymentId,
    super.key,
  });

  final String paymentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsNotifierProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return paymentsAsync.when(
      skipLoadingOnReload: true,
      data: (payments) {
        final payment = payments.cast<PaymentModel?>().firstWhere(
              (p) => p?.id == paymentId,
              orElse: () => null,
            );

        if (payment == null) {
          return const CustomScaffold(
            title: 'Payment Details',
            body: Center(
              child: EmptyStateWidget(
                icon: Icon(Icons.error_outline),
                title: 'Payment Not Found',
                message: 'This payment may have been deleted.',
              ),
            ),
          );
        }

        return CustomScaffold(
          title: 'Payment Details',
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                _buildHeader(payment, theme, cs),
                const SizedBox(height: AppSpacing.xl),

                // Main Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        _buildInfoRow('Project ID', payment.projectId, theme),
                        const Divider(),
                        _buildInfoRow('Reference ID', payment.payeeId, theme),
                        if (payment.invoiceNumber != null && payment.invoiceNumber!.isNotEmpty) ...[
                          const Divider(),
                          _buildInfoRow('Invoice No.', payment.invoiceNumber!, theme),
                        ],
                        if (payment.referenceNumber != null && payment.referenceNumber!.isNotEmpty) ...[
                          const Divider(),
                          _buildInfoRow('Txn/Ref No.', payment.referenceNumber!, theme),
                        ],
                        const Divider(),
                        _buildInfoRow('Date Created', payment.formattedDate, theme),
                        if (payment.dueDate != null) ...[
                          const Divider(),
                          _buildInfoRow('Due Date', payment.formattedDueDate!, theme),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
                Text('Financial Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(child: _SummaryCard(label: 'Total', value: payment.formattedAmount, color: cs.primary)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _SummaryCard(label: 'Paid', value: payment.formattedPaidAmount, color: Colors.green.shade700)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _SummaryCard(label: 'Pending', value: payment.formattedRemainingBalance, color: payment.remainingBalance > 0 ? cs.error : cs.onSurface)),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('Payment History', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                    if (payment.remainingBalance > 0)
                      TextButton.icon(
                        onPressed: () => _showAddHistoryDialog(context, ref, payment),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Payment'),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                
                Consumer(
                  builder: (context, ref, child) {
                    final historyAsync = ref.watch(paymentHistoryProvider(payment.id));
                    return historyAsync.when(
                      skipLoadingOnReload: true,
                      data: (history) {
                        if (history.isEmpty) {
                          return const Center(child: Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Text('No payment history recorded.'),
                          ));
                        }
                        return Column(
                          children: history.map((inst) => Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: cs.primaryContainer,
                                child: Icon(Icons.payment, color: cs.onPrimaryContainer),
                              ),
                              title: Text('Rs. ${inst.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${PaymentModel.methodLabels[inst.paymentMethod]} • ${inst.paymentDate.toString().substring(0, 10)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _showAddHistoryDialog(context, ref, payment, editingHistory: inst),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    color: cs.error,
                                    onPressed: () => _deleteHistory(context, ref, inst, payment.paymentType),
                                  ),
                                ],
                              ),
                            ),
                          )).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('Error: $e')),
                    );
                  },
                ),

                if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text('Notes', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(payment.notes!),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildHeader(PaymentModel payment, ThemeData theme, ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(payment.paymentNumber, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Wrap(
                children: [
                  Chip(
                    label: Text(PaymentModel.typeLabels[payment.paymentType] ?? 'Other'),
                    backgroundColor: cs.tertiaryContainer,
                    side: BorderSide.none,
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: payment.status == PaymentStatus.paid ? Colors.green.shade100 : cs.errorContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            PaymentModel.statusLabels[payment.status] ?? payment.status.name,
            style: TextStyle(
              color: payment.status == PaymentStatus.paid ? Colors.green.shade800 : cs.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _deleteHistory(BuildContext context, WidgetRef ref, PaymentHistoryModel history, PaymentType parentType) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Payment?'),
        content: const Text('Are you sure you want to delete this payment record? The remaining balance will be recalculated.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(paymentsNotifierProvider.notifier).deleteHistory(history, parentType);
    }
  }

  void _showAddHistoryDialog(BuildContext context, WidgetRef ref, PaymentModel payment, {PaymentHistoryModel? editingHistory}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return _AddHistorySheet(payment: payment, editingHistory: editingHistory);
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _AddHistorySheet extends ConsumerStatefulWidget {
  const _AddHistorySheet({required this.payment, this.editingHistory});
  final PaymentModel payment;
  final PaymentHistoryModel? editingHistory;

  @override
  ConsumerState<_AddHistorySheet> createState() => _AddHistorySheetState();
}

class _AddHistorySheetState extends ConsumerState<_AddHistorySheet> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  PaymentMethod _method = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    if (widget.editingHistory != null) {
      _amountCtrl.text = widget.editingHistory!.amount.toStringAsFixed(0);
      _notesCtrl.text = widget.editingHistory!.notes ?? '';
      _date = widget.editingHistory!.paymentDate;
      _method = widget.editingHistory!.paymentMethod;
    } else {
      _amountCtrl.text = widget.payment.remainingBalance.toStringAsFixed(0);
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
    if (amount <= 0) return;
    
    // Prevent overpayment
    final maxAllowed = widget.editingHistory != null 
        ? widget.payment.remainingBalance + widget.editingHistory!.amount
        : widget.payment.remainingBalance;
        
    if (amount > maxAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot exceed remaining balance of Rs. ${maxAllowed.toStringAsFixed(0)}')));
      return;
    }

    if (widget.editingHistory != null) {
      final updated = widget.editingHistory!.copyWith(
        amount: amount,
        paymentDate: _date,
        paymentMethod: _method,
        notes: _notesCtrl.text,
      );
      await ref.read(paymentsNotifierProvider.notifier).updateHistory(updated, widget.payment.paymentType);
    } else {
      final history = PaymentHistoryModel.create(
        paymentId: widget.payment.id,
        amount: amount,
        paymentDate: _date,
        paymentMethod: _method,
        notes: _notesCtrl.text,
      );
      await ref.read(paymentsNotifierProvider.notifier).addHistory(history, widget.payment.paymentType);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          Text(widget.editingHistory != null ? 'Edit Payment' : 'Add Payment', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _amountCtrl,
            labelText: 'Amount',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: _method,
            decoration: const InputDecoration(labelText: 'Method'),
            items: PaymentMethod.values.map((m) {
              return DropdownMenuItem(value: m, child: Text(PaymentModel.methodLabels[m] ?? m.name));
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _method = v);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _notesCtrl,
            labelText: 'Notes (Optional)',
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppPrimaryButton(
                  onPressed: _save,
                  label: 'Save',
                ),
              ),
            ],
          ),
        ],
      ),
    )));
  }
}
