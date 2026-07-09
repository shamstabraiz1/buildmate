import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../data/models/material_model.dart';
import '../../data/models/material_transaction_model.dart';
import '../providers/material_providers.dart';
import '../../../vendors/presentation/providers/vendor_providers.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({
    required this.material,
    super.key,
  });

  final MaterialModel material;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityCtrl = TextEditingController();
  final _unitPriceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  TransactionType _type = TransactionType.purchased;
  DateTime _date = DateTime.now();
  String? _selectedVendorId;
  bool _isSaving = false;

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _unitPriceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _showVendorPicker =>
      _type == TransactionType.purchased ||
      _type == TransactionType.returned;

  bool get _showUnitPrice => _type == TransactionType.purchased;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final txn = MaterialTransactionModel.create(
        materialId: widget.material.id,
        projectId: widget.material.projectId ?? '',
        vendorId: _selectedVendorId,
        type: _type,
        quantity: double.parse(_quantityCtrl.text.trim()),
        unitPrice: _showUnitPrice && _unitPriceCtrl.text.trim().isNotEmpty
            ? double.tryParse(_unitPriceCtrl.text.trim())
            : null,
        date: _date,
        notes: _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim(),
      );

      await ref
          .read(materialsNotifierProvider.notifier)
          .addTransaction(txn);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stock entry recorded for "${widget.material.name}".',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record entry: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final vendorsAsync = ref.watch(vendorsNotifierProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: AppSpacing.sm),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(AppRadius.xxl)),
                    ),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: const BorderRadius.all(
                              Radius.circular(AppRadius.md)),
                        ),
                        child: Icon(Icons.add_shopping_cart_rounded,
                            color: cs.onPrimaryContainer, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Record Stock Entry',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              widget.material.name,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: AppSpacing.xl),

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction Type Selector
                        Text(
                          'Transaction Type',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: TransactionType.values.map((t) {
                            final isSelected = _type == t;
                            final color = _typeColor(t);
                            return FilterChip(
                              label: Text(
                                MaterialTransactionModel.typeLabels[t] ?? t.name,
                              ),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => _type = t),
                              selectedColor: color.withValues(alpha: 0.15),
                              checkmarkColor: color,
                              labelStyle: theme.textTheme.labelMedium?.copyWith(
                                color: isSelected
                                    ? color
                                    : cs.onSurfaceVariant,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? color
                                    : cs.outlineVariant,
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Quantity
                        AppTextField(
                          controller: _quantityCtrl,
                          labelText: 'Quantity (${widget.material.unit}) *',
                          prefixIcon: const Icon(Icons.numbers_rounded),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,4}')),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Quantity is required';
                            }
                            final n = double.tryParse(v);
                            if (n == null || n <= 0) {
                              return 'Enter a valid positive quantity';
                            }
                            return null;
                          },
                        ),

                        if (_showUnitPrice) ...[
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _unitPriceCtrl,
                            labelText: 'Unit Price (Rs.)',
                            prefixIcon:
                                const Icon(Icons.price_change_outlined),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                          ),
                        ],

                        // Vendor picker (for purchased/returned)
                        if (_showVendorPicker) ...[
                          const SizedBox(height: AppSpacing.lg),
                          vendorsAsync.when(
                            data: (vendors) => DropdownButtonFormField<String>(
                            initialValue: _selectedVendorId,
                              decoration: const InputDecoration(
                                labelText: 'Vendor / Supplier',
                                prefixIcon: Icon(Icons.storefront_outlined),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('None'),
                                ),
                                ...vendors.map((v) => DropdownMenuItem(
                                      value: v.id,
                                      child: Text(v.name),
                                    )),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedVendorId = v),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, _) => const SizedBox.shrink(),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.lg),

                        // Date picker
                        InkWell(
                          onTap: () => _pickDate(context),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(AppRadius.md)),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              prefixIcon:
                                  Icon(Icons.calendar_today_outlined),
                            ),
                            child: Text(
                              '${_date.day}/${_date.month}/${_date.year}',
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Notes
                        AppTextField(
                          controller: _notesCtrl,
                          labelText: 'Notes',
                          prefixIcon: const Icon(Icons.notes_outlined),
                          textInputAction: TextInputAction.done,
                          maxLines: 2,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Save button
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _handleSave,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.check_circle_outline_rounded),
                          label: Text(
                              _isSaving ? 'Saving…' : 'Record Entry'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(
                                AppSpacing.controlHeight),
                            shape: const StadiumBorder(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(
                                AppSpacing.controlHeight),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _typeColor(TransactionType t) {
    switch (t) {
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
}
