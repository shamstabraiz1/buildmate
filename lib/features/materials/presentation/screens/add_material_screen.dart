import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../projects/presentation/widgets/project_form_section.dart';
import '../../../vendors/presentation/providers/vendor_providers.dart';
import '../../../vendors/presentation/screens/add_vendor_screen.dart';
import '../../data/models/material_model.dart';
import '../providers/material_providers.dart';
import '../widgets/unit_picker_field.dart';

class AddMaterialScreen extends ConsumerStatefulWidget {
  const AddMaterialScreen({this.material, this.initialProjectId, super.key});

  final MaterialModel? material;
  final String? initialProjectId;

  @override
  ConsumerState<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends ConsumerState<AddMaterialScreen> {
  final _formKey = GlobalKey<FormState>();

  // Section 1 – Material Info
  late final _nameCtrl =
      TextEditingController(text: widget.material?.name);
  late final _customCatCtrl =
      TextEditingController(text: widget.material?.customCategory);
  MaterialCategory? _category;
  String _unit = '';

  // Section 2 – Stock & Pricing
  late final _unitPriceCtrl = TextEditingController(
    text: widget.material?.unitPrice != null
        ? widget.material!.unitPrice.toStringAsFixed(2)
        : '',
  );
  late final _qtyPurchasedCtrl = TextEditingController(
    text: widget.material?.quantityPurchased != null &&
            widget.material!.quantityPurchased > 0
        ? widget.material!.quantityPurchased.toStringAsFixed(2)
        : '',
  );
  late final _reorderCtrl = TextEditingController(
    text: widget.material?.reorderLevel != null
        ? widget.material!.reorderLevel.toStringAsFixed(2)
        : '',
  );

  // Section 3 – Project
  String? _selectedProjectId;

  // Section 4 – Vendor
  String? _selectedVendorId;

  // Section 5 – Optional
  String? _imagePath;
  late final _notesCtrl =
      TextEditingController(text: widget.material?.notes);

  bool _isSaving = false;

  bool get _isEdit => widget.material != null;

  @override
  void initState() {
    super.initState();
    _category = widget.material?.category;
    _unit = widget.material?.unit ?? '';
    _selectedProjectId = widget.material?.projectId ?? widget.initialProjectId;
    _selectedVendorId = widget.material?.vendorId;
    _imagePath = widget.material?.imagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _customCatCtrl.dispose();
    _unitPriceCtrl.dispose();
    _qtyPurchasedCtrl.dispose();
    _reorderCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double? get _totalCost {
    final price = double.tryParse(_unitPriceCtrl.text);
    final qty = double.tryParse(_qtyPurchasedCtrl.text);
    if (price != null && qty != null) return price * qty;
    return null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a category.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (_unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a unit of measurement.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final unitPrice =
          double.tryParse(_unitPriceCtrl.text.trim()) ?? 0;
      final qtyPurchased =
          double.tryParse(_qtyPurchasedCtrl.text.trim()) ?? 0;
      final reorder =
          double.tryParse(_reorderCtrl.text.trim()) ?? 0;

      if (_isEdit) {
        final updated = widget.material!.copyWith(
          name: _nameCtrl.text.trim(),
          category: _category,
          customCategory: _category == MaterialCategory.custom
              ? _customCatCtrl.text.trim()
              : null,
          clearCustomCategory: _category != MaterialCategory.custom,
          unit: _unit,
          unitPrice: unitPrice,
          quantityPurchased: qtyPurchased,
          reorderLevel: reorder,
          projectId: _selectedProjectId,
          clearProjectId: _selectedProjectId == null,
          vendorId: _selectedVendorId,
          clearVendorId: _selectedVendorId == null,
          imagePath: _imagePath,
          clearImagePath: _imagePath == null,
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
          clearNotes: _notesCtrl.text.trim().isEmpty,
        );
        await ref
            .read(materialsNotifierProvider.notifier)
            .updateMaterial(updated);
      } else {
        final newMaterial = MaterialModel.create(
          name: _nameCtrl.text.trim(),
          category: _category!,
          customCategory: _category == MaterialCategory.custom
              ? _customCatCtrl.text.trim()
              : null,
          unit: _unit,
          unitPrice: unitPrice,
          quantityPurchased: qtyPurchased,
          reorderLevel: reorder,
          projectId: _selectedProjectId,
          vendorId: _selectedVendorId,
          imagePath: _imagePath,
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
        );
        await ref
            .read(materialsNotifierProvider.notifier)
            .addMaterial(newMaterial);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEdit
                  ? 'Material updated successfully.'
                  : '"${_nameCtrl.text.trim()}" added to inventory.',
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
            content: Text('Failed to save: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(projectsNotifierProvider);
    final vendorsAsync = ref.watch(vendorsNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: _isEdit ? 'Edit Material' : 'Add Material',
        subtitle: _isEdit
            ? 'Update material details'
            : 'Register a new stock item',
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
                  // ── Section 1: Material Info ───────────────────────────
                  ProjectFormSection(
                    title: 'Material Info',
                    icon: Icons.inventory_2_outlined,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _nameCtrl,
                          labelText: 'Material Name *',
                          prefixIcon: const Icon(Icons.label_outline_rounded),
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Name is required'
                                  : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Category dropdown
                        DropdownButtonFormField<MaterialCategory>(
                          initialValue: _category,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            prefixIcon:
                                Icon(Icons.category_outlined),
                          ),
                          items: MaterialCategory.values.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(
                                MaterialModel.categoryLabels[cat] ??
                                    cat.name,
                              ),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _category = v),
                          validator: (v) =>
                              v == null ? 'Category is required' : null,
                        ),

                        // Custom category text field
                        if (_category == MaterialCategory.custom) ...[
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _customCatCtrl,
                            labelText: 'Custom Category Name *',
                            prefixIcon:
                                const Icon(Icons.edit_note_outlined),
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                _category == MaterialCategory.custom &&
                                        (v == null || v.trim().isEmpty)
                                    ? 'Custom category name is required'
                                    : null,
                          ),
                        ],

                        const SizedBox(height: AppSpacing.lg),

                        // Unit picker
                        UnitPickerField(
                          initialValue: _unit.isEmpty ? null : _unit,
                          onChanged: (u) =>
                              setState(() => _unit = u),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Section 2: Stock & Pricing ─────────────────────────
                  ProjectFormSection(
                    title: 'Stock & Pricing',
                    icon: Icons.price_change_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: _unitPriceCtrl,
                          labelText: 'Unit Price (Rs.) *',
                          prefixIcon:
                              const Icon(Icons.currency_rupee_rounded),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Unit price is required';
                            }
                            if (double.tryParse(v) == null) {
                              return 'Enter a valid price';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _qtyPurchasedCtrl,
                          labelText: 'Initial Quantity Purchased',
                          hintText: 'Leave 0 if starting fresh',
                          prefixIcon:
                              const Icon(Icons.add_shopping_cart_rounded),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,4}')),
                          ],
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _reorderCtrl,
                          labelText: 'Reorder Level *',
                          hintText: 'Alert when remaining drops below this',
                          prefixIcon:
                              const Icon(Icons.warning_amber_rounded),
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
                              return 'Reorder level is required';
                            }
                            if (double.tryParse(v) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),

                        // Total cost preview
                        if (_totalCost != null && _totalCost! > 0) ...[
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer
                                  .withValues(alpha: 0.4),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(8)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calculate_outlined,
                                    size: 16,
                                    color: cs.onPrimaryContainer),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Total Cost: Rs. ${_totalCost!.toStringAsFixed(2)}',
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Section 3: Project Assignment ──────────────────────
                  ProjectFormSection(
                    title: 'Project Assignment',
                    icon: Icons.folder_outlined,
                    child: projectsAsync.when(
                      data: (projects) => DropdownButtonFormField<String>(
                        initialValue: _selectedProjectId,
                        decoration: const InputDecoration(
                          labelText: 'Assign to Project (Optional)',
                          prefixIcon: Icon(Icons.business_center_outlined),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Global Inventory (No Project)'),
                          ),
                          ...projects.map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedProjectId = v),
                      ),
                      loading: () => const SizedBox(
                        height: 48,
                        child: Center(
                            child: LinearProgressIndicator()),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Section 4: Vendor/Supplier ────────────────────────
                  ProjectFormSection(
                    title: 'Vendor / Supplier',
                    icon: Icons.local_shipping_outlined,
                    child: Column(
                      children: [
                        vendorsAsync.when(
                          data: (vendors) =>
                              DropdownButtonFormField<String>(
                            initialValue: _selectedVendorId,
                            decoration: const InputDecoration(
                              labelText: 'Primary Vendor (Optional)',
                              prefixIcon:
                                  Icon(Icons.storefront_outlined),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('None'),
                              ),
                              ...vendors.map(
                                (v) => DropdownMenuItem(
                                  value: v.id,
                                  child: Text(v.name,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _selectedVendorId = v),
                          ),
                          loading: () => const SizedBox(
                            height: 48,
                            child: Center(
                                child: LinearProgressIndicator()),
                          ),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddVendorScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_business_rounded,
                              size: 16),
                          label: const Text('Add New Vendor'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Section 5: Optional Details ───────────────────────
                  ProjectFormSection(
                    title: 'Optional Details',
                    icon: Icons.photo_library_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Picker
                        if (!kIsWeb) ...[
                          Text(
                            'Material Photo',
                            style:
                                theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: cs.outlineVariant,
                                    style: BorderStyle.solid),
                                borderRadius:
                                    const BorderRadius.all(
                                        Radius.circular(8)),
                                color: cs.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                              ),
                              child: _imagePath != null
                                  ? ClipRRect(
                                      borderRadius:
                                          const BorderRadius.all(
                                              Radius.circular(8)),
                                      child: Image.file(
                                        File(_imagePath!),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                            Icons.add_photo_alternate_outlined,
                                            color:
                                                cs.onSurfaceVariant,
                                            size: 32),
                                        const SizedBox(
                                            height: AppSpacing.xs),
                                        Text('Add Photo',
                                            style: theme.textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: cs
                                                        .onSurfaceVariant)),
                                      ],
                                    ),
                            ),
                          ),
                          if (_imagePath != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            TextButton.icon(
                              onPressed: () =>
                                  setState(() => _imagePath = null),
                              icon: const Icon(Icons.close, size: 14),
                              label: const Text('Remove Photo'),
                              style: TextButton.styleFrom(
                                foregroundColor: cs.error,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        AppTextField(
                          controller: _notesCtrl,
                          labelText: 'Notes',
                          prefixIcon:
                              const Icon(Icons.notes_outlined),
                          textInputAction: TextInputAction.done,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // ── Save / Cancel ─────────────────────────────────────
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
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(
                      _isSaving
                          ? 'Saving…'
                          : _isEdit
                              ? 'Update Material'
                              : 'Save Material',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize:
                          const Size.fromHeight(AppSpacing.controlHeight),
                      shape: const StadiumBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize:
                          const Size.fromHeight(AppSpacing.controlHeight),
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
