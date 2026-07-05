import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../projects/presentation/widgets/project_form_section.dart';
import '../../data/expenses_dummy_data.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  ExpenseCategory? _selectedCategory;
  PaymentMethod? _selectedPaymentMethod;

  bool _hasReceiptAttached = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete all required dropdowns.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense logged successfully.'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  void _handleReceiptUpload() async {
    // Mocking file upload delay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.of(context).pop(); // dismiss loading
    setState(() {
      _hasReceiptAttached = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt uploaded successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Add Expense',
        subtitle: 'Log a new project cost',
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  ProjectFormSection(
                    title: 'Expense Details',
                    icon: Icons.receipt_long_outlined,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _titleCtrl,
                          labelText: 'Title / Description *',
                          prefixIcon: const Icon(Icons.short_text_rounded),
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _amountCtrl,
                          labelText: 'Amount (₹) *',
                          prefixIcon: const Icon(Icons.currency_rupee_rounded),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Amount is required';
                            if (double.tryParse(v) == null) return 'Enter a valid amount';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        DropdownButtonFormField<ExpenseCategory>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: ExpenseCategory.values.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(ExpensesDummyData.categoryLabels[cat] ?? ''),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v),
                          validator: (v) => v == null ? 'Category is required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ProjectFormSection(
                    title: 'Payment Info',
                    icon: Icons.payments_outlined,
                    child: Column(
                      children: [
                        DropdownButtonFormField<PaymentMethod>(
                          initialValue: _selectedPaymentMethod,
                          decoration: const InputDecoration(
                            labelText: 'Payment Method *',
                            prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                          ),
                          items: PaymentMethod.values.map((pm) {
                            return DropdownMenuItem(
                              value: pm,
                              child: Text(ExpensesDummyData.paymentMethodLabels[pm] ?? ''),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedPaymentMethod = v),
                          validator: (v) => v == null ? 'Payment Method is required' : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _notesCtrl,
                          labelText: 'Notes (Optional)',
                          hintText: 'Any additional context...',
                          prefixIcon: const Icon(Icons.notes_outlined),
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ProjectFormSection(
                    title: 'Attachments',
                    icon: Icons.attach_file_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_hasReceiptAttached)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: colorScheme.successContainer,
                              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
                              border: Border.all(color: colorScheme.success),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: colorScheme.onSuccessContainer),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    'Receipt Attached successfully.',
                                    style: TextStyle(color: colorScheme.onSuccessContainer, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: colorScheme.onSuccessContainer),
                                  onPressed: () => setState(() => _hasReceiptAttached = false),
                                  tooltip: 'Remove Receipt',
                                ),
                              ],
                            ),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: _handleReceiptUpload,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Upload Receipt / Bill'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(80),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
                              ),
                              side: BorderSide(
                                color: colorScheme.primary.withValues(alpha: 0.5),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  FilledButton.icon(
                    onPressed: _handleSave,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Save Expense'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppSpacing.controlHeight),
                      shape: const StadiumBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppSpacing.controlHeight),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on ColorScheme {
  Color get successContainer => const Color(0xFFCEEAD6);
  Color get onSuccessContainer => const Color(0xFF0D652D);
  Color get success => const Color(0xFF1E8E3E);
}
