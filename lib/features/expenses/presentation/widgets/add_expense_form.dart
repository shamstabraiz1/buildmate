import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/buttons/app_outlined_button.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../projects/presentation/widgets/project_date_field.dart';
import '../../../projects/presentation/widgets/project_form_section.dart';
import '../../data/models/expense_model.dart';

class AddExpenseForm extends ConsumerStatefulWidget {
  const AddExpenseForm({
    required this.onSave,
    required this.onCancel,
    this.expense,
    this.initialProjectId,
    super.key,
  });

  final ValueChanged<Map<String, dynamic>> onSave;
  final VoidCallback onCancel;
  final ExpenseModel? expense;
  final String? initialProjectId;

  @override
  ConsumerState<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends ConsumerState<AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ───────────────────────────────────────────────────────────
  late final TextEditingController _amountCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _vendorCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _customCategoryCtrl;

  // ── State ────────────────────────────────────────────────────────────
  String? _selectedProjectId;
  String? _selectedCategory;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  ExpenseStatus _selectedStatus = ExpenseStatus.paid;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _amountCtrl = TextEditingController(text: e?.amount.toStringAsFixed(2) ?? '');
    _quantityCtrl = TextEditingController(text: e?.quantity?.toStringAsFixed(2) ?? '');
    _unitCtrl = TextEditingController(text: e?.unit ?? '');
    _vendorCtrl = TextEditingController(text: e?.vendor ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    
    _selectedProjectId = e?.projectId ?? widget.initialProjectId;
    _selectedPaymentMethod = e?.paymentMethod ?? PaymentMethod.cash;
    _selectedStatus = e?.status ?? ExpenseStatus.paid;
    _date = e?.date ?? DateTime.now();

    if (e != null) {
      if (ExpenseModel.predefinedCategories.contains(e.categoryId)) {
        _selectedCategory = e.categoryId;
        _customCategoryCtrl = TextEditingController();
      } else {
        _selectedCategory = 'Custom';
        _customCategoryCtrl = TextEditingController(text: e.categoryId);
      }
    } else {
      _customCategoryCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _quantityCtrl.dispose();
    _unitCtrl.dispose();
    _vendorCtrl.dispose();
    _notesCtrl.dispose();
    _customCategoryCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project.')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
      return;
    }

    String categoryId = _selectedCategory!;
    if (categoryId == 'Custom') {
      if (_customCategoryCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a custom category.')),
        );
        return;
      }
      categoryId = _customCategoryCtrl.text.trim();
    }

    widget.onSave({
      'projectId': _selectedProjectId,
      'categoryId': categoryId,
      'amount': double.parse(_amountCtrl.text.replaceAll(',', '')),
      'date': _date,
      'quantity': _quantityCtrl.text.isNotEmpty ? double.parse(_quantityCtrl.text) : null,
      'unit': _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
      'vendor': _vendorCtrl.text.trim().isEmpty ? null : _vendorCtrl.text.trim(),
      'paymentMethod': _selectedPaymentMethod,
      'status': _selectedStatus,
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsNotifierProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Basic Info ──────────────────────────────────────────────────
          ProjectFormSection(
            title: 'Expense Details',
            icon: Icons.receipt_long_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Selection
                if (projectsState.hasValue) ...[
                  DropdownButtonFormField<String>(
                  initialValue: _selectedProjectId,
                    decoration: const InputDecoration(
                      labelText: 'Project *',
                      border: OutlineInputBorder(),
                    ),
                    items: projectsState.value!.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedProjectId = val),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Category Selection
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    ...ExpenseModel.predefinedCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    const DropdownMenuItem(value: 'Custom', child: Text('Other (Custom)')),
                  ],
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  validator: (v) => v == null ? 'Required' : null,
                ),

                if (_selectedCategory == 'Custom') ...[
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _customCategoryCtrl,
                    labelText: 'Custom Category *',
                    hintText: 'e.g. Architect Fees',
                    prefixIcon: const Icon(Icons.category_outlined),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ],

                const SizedBox(height: AppSpacing.md),
                
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        controller: _amountCtrl,
                        labelText: 'Amount (Rs.) *',
                        hintText: '0.00',
                        prefixIcon: const Icon(Icons.currency_rupee_rounded),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (double.tryParse(v.replaceAll(',', '')) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: ProjectDateField(
                      labelText: 'Date *',
                      selectedDate: _date,
                      onDateSelected: (d) => setState(() => _date = d),
                    ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Additional Details ──────────────────────────────────────────
          ProjectFormSection(
            title: 'Additional Details (Optional)',
            icon: Icons.info_outline_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _quantityCtrl,
                        labelText: 'Quantity',
                        hintText: 'e.g. 100',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        controller: _unitCtrl,
                        labelText: 'Unit',
                        hintText: 'e.g. bags, tons, sqft',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _vendorCtrl,
                  labelText: 'Vendor / Supplier',
                  hintText: 'e.g. Ali Hardware',
                  prefixIcon: const Icon(Icons.storefront_outlined),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<PaymentMethod>(
                        initialValue: _selectedPaymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                        ),
                        items: PaymentMethod.values.map((pm) {
                          return DropdownMenuItem(
                            value: pm,
                            child: Text(ExpenseModel.paymentMethodLabels[pm]!),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedPaymentMethod = val);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DropdownButtonFormField<ExpenseStatus>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: ExpenseStatus.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(ExpenseModel.statusLabels[s]!),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStatus = val);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Notes ───────────────────────────────────────────────────────
          ProjectFormSection(
            title: 'Notes',
            icon: Icons.notes_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _notesCtrl,
                  labelText: 'Additional Information',
                  hintText: 'Any remarks or details...',
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ── Actions ─────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  onPressed: widget.onCancel,
                  label: 'Cancel',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: AppPrimaryButton(
                  onPressed: _handleSave,
                  label: 'Save Expense',
                  icon: const Icon(Icons.check_circle_outline_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
