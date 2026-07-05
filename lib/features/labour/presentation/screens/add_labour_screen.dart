import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../projects/presentation/widgets/project_form_section.dart';
import '../../data/labour_dummy_data.dart';

class AddLabourScreen extends StatefulWidget {
  const AddLabourScreen({super.key});

  @override
  State<AddLabourScreen> createState() => _AddLabourScreenState();
}

class _AddLabourScreenState extends State<AddLabourScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _wageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  LabourRole? _selectedRole;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _wageCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a role.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Worker "${_nameCtrl.text}" added successfully.'),
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
        title: 'Add Worker',
        subtitle: 'Register a new labour resource',
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
                    title: 'Personal Info',
                    icon: Icons.person_outline_rounded,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _nameCtrl,
                          labelText: 'Full Name *',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _phoneCtrl,
                          labelText: 'Phone Number *',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Phone is required';
                            if (v.length < 10) return 'Enter a valid 10-digit number';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _addressCtrl,
                          labelText: 'Address',
                          prefixIcon: const Icon(Icons.home_outlined),
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ProjectFormSection(
                    title: 'Work Details',
                    icon: Icons.work_outline_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<LabourRole>(
                          initialValue: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Role / Skill *',
                            prefixIcon: Icon(Icons.construction_rounded),
                          ),
                          items: LabourRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(LabourDummyData.roleLabels[role] ?? ''),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedRole = v),
                          validator: (v) => v == null ? 'Role is required' : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _wageCtrl,
                          labelText: 'Daily Wage (₹) *',
                          prefixIcon: const Icon(Icons.currency_rupee_rounded),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Daily wage is required';
                            if (double.tryParse(v) == null) return 'Enter a valid amount';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  FilledButton.icon(
                    onPressed: _handleSave,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Save Worker'),
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
