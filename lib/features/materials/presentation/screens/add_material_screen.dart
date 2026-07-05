import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../projects/presentation/widgets/project_form_section.dart';
import '../../data/materials_dummy_data.dart';

class AddMaterialScreen extends StatefulWidget {
  const AddMaterialScreen({super.key});

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _reorderCtrl = TextEditingController();

  MaterialCategory? _selectedCategory;
  String? _selectedSupplierId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    _quantityCtrl.dispose();
    _reorderCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a material category.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Material "${_nameCtrl.text}" added successfully.'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Add Material',
        subtitle: 'Register new stock item',
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
                    title: 'Material Info',
                    icon: Icons.inventory_2_outlined,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _nameCtrl,
                          labelText: 'Material Name *',
                          prefixIcon: const Icon(Icons.label_outline_rounded),
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        DropdownButtonFormField<MaterialCategory>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: MaterialCategory.values.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(MaterialsDummyData.categoryLabels[cat] ?? ''),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v),
                          validator: (v) => v == null ? 'Category is required' : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _unitCtrl,
                          labelText: 'Unit of Measurement *',
                          hintText: 'e.g., Bags, Tons, Liters',
                          prefixIcon: const Icon(Icons.square_foot_outlined),
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Unit is required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ProjectFormSection(
                    title: 'Stock Settings',
                    icon: Icons.trending_up_rounded,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _quantityCtrl,
                          labelText: 'Initial Quantity *',
                          prefixIcon: const Icon(Icons.numbers_rounded),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Initial quantity is required';
                            if (double.tryParse(v) == null) return 'Enter a valid number';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _reorderCtrl,
                          labelText: 'Reorder Level *',
                          hintText: 'Alert when stock falls below this',
                          prefixIcon: const Icon(Icons.warning_amber_rounded),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Reorder level is required';
                            if (double.tryParse(v) == null) return 'Enter a valid number';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ProjectFormSection(
                    title: 'Primary Supplier',
                    icon: Icons.local_shipping_outlined,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedSupplierId,
                      decoration: const InputDecoration(
                        labelText: 'Select Supplier (Optional)',
                        prefixIcon: Icon(Icons.storefront_outlined),
                      ),
                      items: MaterialsDummyData.suppliers.map((sup) {
                        return DropdownMenuItem(
                          value: sup.id,
                          child: Text(sup.companyName),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedSupplierId = v),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  FilledButton.icon(
                    onPressed: _handleSave,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Save Material'),
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
