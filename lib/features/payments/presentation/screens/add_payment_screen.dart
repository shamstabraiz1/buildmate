import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/layout/custom_scaffold.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../vendors/presentation/providers/vendor_providers.dart';
import '../../../labour/presentation/providers/labour_providers.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../data/models/payment_history_model.dart';
import '../../data/models/payment_model.dart';
import '../providers/payment_providers.dart';

class AddPaymentScreen extends ConsumerStatefulWidget {
  const AddPaymentScreen({this.paymentId, this.initialProjectId, super.key});

  final String? paymentId;
  final String? initialProjectId;

  @override
  ConsumerState<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends ConsumerState<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  late String? _selectedProjectId = widget.initialProjectId;
  PaymentType _selectedType = PaymentType.vendor;
  String? _selectedPayeeId; // Vendor ID, Labour ID, Expense ID
  String _otherPayeeName = '';
  
  final _amountCtrl = TextEditingController();
  final _paidAmountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _dueDateCtrl = TextEditingController();
  final _invoiceNumberCtrl = TextEditingController();
  final _referenceNumberCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedDueDate;
  PaymentMethod _selectedMethod = PaymentMethod.cash;

  bool _isLoading = false;
  PaymentModel? _editingPayment;

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = _selectedDate.toString().substring(0, 10);
    
    if (widget.paymentId != null) {
      _loadPayment();
    }
  }

  Future<void> _loadPayment() async {
    final payment = await ref.read(paymentRepositoryProvider).getPaymentById(widget.paymentId!);
    if (payment != null) {
      setState(() {
        _editingPayment = payment;
        _selectedProjectId = payment.projectId;
        _selectedType = payment.paymentType;
        if (_selectedType == PaymentType.other) {
          _otherPayeeName = payment.payeeId;
        } else {
          _selectedPayeeId = payment.payeeId;
        }
        _amountCtrl.text = payment.amount.toStringAsFixed(0);
        _selectedDate = payment.date;
        _dateCtrl.text = _selectedDate.toString().substring(0, 10);
        
        if (payment.dueDate != null) {
          _selectedDueDate = payment.dueDate;
          _dueDateCtrl.text = _selectedDueDate.toString().substring(0, 10);
        }

        _selectedMethod = payment.paymentMethod;
        _invoiceNumberCtrl.text = payment.invoiceNumber ?? '';
        _referenceNumberCtrl.text = payment.referenceNumber ?? '';
        _notesCtrl.text = payment.notes ?? '';
      });
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _paidAmountCtrl.dispose();
    _dateCtrl.dispose();
    _dueDateCtrl.dispose();
    _invoiceNumberCtrl.dispose();
    _referenceNumberCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl, bool isDueDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? (_selectedDueDate ?? DateTime.now()) : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        ctrl.text = picked.toString().substring(0, 10);
        if (isDueDate) {
          _selectedDueDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a project')));
      return;
    }
    if (_selectedType != PaymentType.other && _selectedPayeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a payee')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountCtrl.text.trim());
      final paidAmount = _paidAmountCtrl.text.trim().isNotEmpty ? double.parse(_paidAmountCtrl.text.trim()) : 0.0;
      final payeeId = _selectedType == PaymentType.other ? _otherPayeeName : _selectedPayeeId!;

      if (_editingPayment != null) {
        final updated = _editingPayment!.copyWith(
          projectId: _selectedProjectId,
          paymentType: _selectedType,
          payeeId: payeeId,
          amount: amount,
          date: _selectedDate,
          dueDate: _selectedDueDate,
          paymentMethod: _selectedMethod,
          invoiceNumber: _invoiceNumberCtrl.text.trim(),
          referenceNumber: _referenceNumberCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
        );
        await ref.read(paymentsNotifierProvider.notifier).updatePayment(updated);
      } else {
        final newPayment = PaymentModel.create(
          projectId: _selectedProjectId!,
          payeeId: payeeId,
          paymentType: _selectedType,
          amount: amount,
          date: _selectedDate,
          dueDate: _selectedDueDate,
          paymentMethod: _selectedMethod,
          invoiceNumber: _invoiceNumberCtrl.text.trim(),
          referenceNumber: _referenceNumberCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
        );
        await ref.read(paymentsNotifierProvider.notifier).addPayment(newPayment);
        
        if (paidAmount > 0) {
          final history = PaymentHistoryModel.create(
            paymentId: newPayment.id,
            amount: paidAmount,
            paymentDate: _selectedDate,
            paymentMethod: _selectedMethod,
            notes: 'Initial payment',
          );
          await ref.read(paymentsNotifierProvider.notifier).addHistory(history, _selectedType);
        }
      }
      
      if (!mounted) return;
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: widget.paymentId == null ? 'New Payment' : 'Edit Payment',
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('General Details'),
              _buildProjectDropdown(),
              const SizedBox(height: AppSpacing.md),
              _buildPaymentTypeDropdown(),
              const SizedBox(height: AppSpacing.md),
              _buildPayeeSelector(),
              
              const SizedBox(height: AppSpacing.xxl),
              _buildSectionTitle('Financials'),
              AppTextField(
                controller: _amountCtrl,
                labelText: 'Total Amount Due *',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.money),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              if (_editingPayment == null)
                AppTextField(
                  controller: _paidAmountCtrl,
                  labelText: 'Amount Paid (Now)',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.payments_outlined),
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty && double.tryParse(v) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: AppSpacing.md),
              _buildMethodDropdown(),

              const SizedBox(height: AppSpacing.xxl),
              _buildSectionTitle('Dates & References'),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(_dateCtrl, false),
                      child: AbsorbPointer(
                        child: AppTextField(
                          controller: _dateCtrl,
                          labelText: 'Payment Date *',
                          readOnly: true,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(_dueDateCtrl, true),
                      child: AbsorbPointer(
                        child: AppTextField(
                          controller: _dueDateCtrl,
                          labelText: 'Due Date',
                          readOnly: true,
                          prefixIcon: const Icon(Icons.event_outlined),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _invoiceNumberCtrl,
                labelText: 'Invoice Number (Optional)',
                prefixIcon: const Icon(Icons.receipt_outlined),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _referenceNumberCtrl,
                labelText: 'Transaction / Ref No. (Optional)',
                prefixIcon: const Icon(Icons.numbers_outlined),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              _buildSectionTitle('Additional Info'),
              AppTextField(
                controller: _notesCtrl,
                labelText: 'Notes',
                maxLines: 3,
                prefixIcon: const Icon(Icons.notes_outlined),
              ),

              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Save Payment',
                  onPressed: _isLoading ? null : _save,
                  isLoading: _isLoading,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildProjectDropdown() {
    final projectsAsync = ref.watch(projectsNotifierProvider);
    return projectsAsync.when(
      data: (projects) {
        return DropdownButtonFormField<String>(
          initialValue: _selectedProjectId,
          decoration: const InputDecoration(labelText: 'Project *', prefixIcon: Icon(Icons.business_center_outlined)),
          items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
          onChanged: (v) => setState(() => _selectedProjectId = v),
          validator: (v) => v == null ? 'Please select a project' : null,
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (err, stack) => const Text('Error loading projects'),
    );
  }

  Widget _buildPaymentTypeDropdown() {
    return DropdownButtonFormField<PaymentType>(
      initialValue: _selectedType,
      decoration: const InputDecoration(labelText: 'Payment Type *', prefixIcon: Icon(Icons.category_outlined)),
      items: PaymentType.values.map((t) => DropdownMenuItem(value: t, child: Text(PaymentModel.typeLabels[t] ?? t.name))).toList(),
      onChanged: (v) {
        if (v != null) {
          setState(() {
            _selectedType = v;
            _selectedPayeeId = null;
          });
        }
      },
    );
  }

  Widget _buildPayeeSelector() {
    switch (_selectedType) {
      case PaymentType.vendor:
        final vendorsAsync = ref.watch(vendorsNotifierProvider);
        return vendorsAsync.when(
          data: (vendors) => DropdownButtonFormField<String>(
            initialValue: _selectedPayeeId,
            decoration: const InputDecoration(labelText: 'Vendor *', prefixIcon: Icon(Icons.storefront_outlined)),
            items: vendors.map((v) => DropdownMenuItem(value: v.id, child: Text(v.name))).toList(),
            onChanged: (v) => setState(() => _selectedPayeeId = v),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (err, stack) => const Text('Error loading vendors'),
        );
      case PaymentType.labour:
        final laboursAsync = ref.watch(laboursNotifierProvider);
        return laboursAsync.when(
          data: (labours) => DropdownButtonFormField<String>(
            initialValue: _selectedPayeeId,
            decoration: const InputDecoration(labelText: 'Labour / Contractor *', prefixIcon: Icon(Icons.engineering_outlined)),
            items: labours.map((l) => DropdownMenuItem(value: l.id, child: Text(l.name))).toList(),
            onChanged: (v) => setState(() => _selectedPayeeId = v),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (err, stack) => const Text('Error loading labours'),
        );
      case PaymentType.expense:
        final expensesAsync = ref.watch(expensesNotifierProvider);
        return expensesAsync.when(
          data: (expenses) => DropdownButtonFormField<String>(
            initialValue: _selectedPayeeId,
            decoration: const InputDecoration(labelText: 'Expense Reference *', prefixIcon: Icon(Icons.receipt_long_outlined)),
            items: expenses.map((e) => DropdownMenuItem(value: e.id, child: Text('${e.expenseNumber} - ${e.categoryId}'))).toList(),
            onChanged: (v) => setState(() => _selectedPayeeId = v),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (err, stack) => const Text('Error loading expenses'),
        );
      case PaymentType.other:
        return AppTextField(
          initialValue: _otherPayeeName,
          labelText: 'Payee Name *',
          prefixIcon: const Icon(Icons.person_outline),
          onChanged: (v) => _otherPayeeName = v,
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        );
    }
  }

  Widget _buildMethodDropdown() {
    return DropdownButtonFormField<PaymentMethod>(
      initialValue: _selectedMethod,
      decoration: const InputDecoration(labelText: 'Payment Method *', prefixIcon: Icon(Icons.payment_outlined)),
      items: PaymentMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(PaymentModel.methodLabels[m] ?? m.name))).toList(),
      onChanged: (v) {
        if (v != null) setState(() => _selectedMethod = v);
      },
    );
  }
}
