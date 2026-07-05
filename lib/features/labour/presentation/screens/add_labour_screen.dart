import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/local_image_display.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../projects/presentation/widgets/project_form_section.dart';
import '../../data/models/labour_model.dart';
import '../providers/labour_providers.dart';

class AddLabourScreen extends ConsumerStatefulWidget {
  const AddLabourScreen({super.key, this.labourToEdit});
  final LabourModel? labourToEdit;

  @override
  ConsumerState<AddLabourScreen> createState() => _AddLabourScreenState();
}

class _AddLabourScreenState extends ConsumerState<AddLabourScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _wageCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cnicCtrl;
  late final TextEditingController _overtimeRateCtrl;
  late final TextEditingController _customRoleCtrl;
  late final TextEditingController _notesCtrl;

  LabourRole? _selectedRole;
  String? _imagePath;

  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final l = widget.labourToEdit;
    _nameCtrl = TextEditingController(text: l?.name);
    _phoneCtrl = TextEditingController(text: l?.phone);
    _wageCtrl = TextEditingController(text: l?.dailyRate.toString());
    _addressCtrl = TextEditingController(text: l?.address);
    _cnicCtrl = TextEditingController(text: l?.cnic);
    _overtimeRateCtrl = TextEditingController(text: l?.overtimeRate?.toString());
    _customRoleCtrl = TextEditingController(text: l?.customRole);
    _notesCtrl = TextEditingController(text: l?.notes);
    _selectedRole = l?.role;
    _imagePath = l?.imagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _wageCtrl.dispose();
    _addressCtrl.dispose();
    _cnicCtrl.dispose();
    _overtimeRateCtrl.dispose();
    _customRoleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_imagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Remove image', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _imagePath = null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
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

    if (_selectedRole == LabourRole.custom && _customRoleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the custom role.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final name = _nameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();
      final dailyRate = double.parse(_wageCtrl.text.trim());
      final address = _addressCtrl.text.trim();
      final cnic = _cnicCtrl.text.trim();
      final overtimeRateText = _overtimeRateCtrl.text.trim();
      final overtimeRate = overtimeRateText.isNotEmpty ? double.parse(overtimeRateText) : null;
      final customRole = _customRoleCtrl.text.trim();
      final notes = _notesCtrl.text.trim();

      if (widget.labourToEdit == null) {
        final newLabour = LabourModel.create(
          name: name,
          phone: phone,
          role: _selectedRole!,
          dailyRate: dailyRate,
          address: address.isEmpty ? null : address,
          cnic: cnic.isEmpty ? null : cnic,
          overtimeRate: overtimeRate,
          imagePath: _imagePath,
          customRole: _selectedRole == LabourRole.custom && customRole.isNotEmpty ? customRole : null,
          notes: notes.isEmpty ? null : notes,
        );
        await ref.read(laboursNotifierProvider.notifier).addLabour(newLabour);
      } else {
        final updated = widget.labourToEdit!.copyWith(
          name: name,
          phone: phone,
          role: _selectedRole,
          dailyRate: dailyRate,
          address: address.isEmpty ? null : address,
          cnic: cnic.isEmpty ? null : cnic,
          overtimeRate: overtimeRate,
          imagePath: _imagePath,
          customRole: _selectedRole == LabourRole.custom && customRole.isNotEmpty ? customRole : null,
          notes: notes.isEmpty ? null : notes,
        );
        await ref.read(laboursNotifierProvider.notifier).updateLabour(updated);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Worker "$name" saved successfully.'),
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
            content: Text('Error saving worker: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.labourToEdit != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Worker' : 'Add Worker',
        subtitle: isEditing ? 'Update labour details' : 'Register a new labour resource',
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
                  // Profile Image Picker
                  Center(
                    child: GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _imagePath != null
                                ? LocalImageDisplay(imagePath: _imagePath!, width: 100, height: 100)
                                : Icon(Icons.person, size: 50, color: colorScheme.onSurfaceVariant),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.camera_alt, size: 16, color: colorScheme.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

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
                            LengthLimitingTextInputFormatter(11),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Phone is required';
                            if (v.length < 10) return 'Enter a valid number';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _cnicCtrl,
                          labelText: 'CNIC',
                          prefixIcon: const Icon(Icons.credit_card_outlined),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
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
                              child: Text(LabourModel.roleLabels[role] ?? ''),
                            );
                          }).toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedRole = v;
                            });
                          },
                          validator: (v) => v == null ? 'Role is required' : null,
                        ),
                        if (_selectedRole == LabourRole.custom) ...[
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _customRoleCtrl,
                            labelText: 'Custom Role *',
                            prefixIcon: const Icon(Icons.handyman_outlined),
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (_selectedRole == LabourRole.custom && (v == null || v.trim().isEmpty)) {
                                return 'Custom role is required';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _wageCtrl,
                          labelText: 'Daily Wage (Rs) *',
                          prefixIcon: const Icon(Icons.payments_outlined),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Daily wage is required';
                            if (double.tryParse(v) == null) return 'Enter a valid amount';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _overtimeRateCtrl,
                          labelText: 'Overtime Rate / Hr (Optional)',
                          prefixIcon: const Icon(Icons.more_time_rounded),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ProjectFormSection(
                    title: 'Additional Info',
                    icon: Icons.notes_outlined,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _notesCtrl,
                          labelText: 'Notes',
                          prefixIcon: const Icon(Icons.edit_note_rounded),
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _handleSave,
                    icon: _isSaving 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(isEditing ? 'Update Worker' : 'Save Worker'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppSpacing.controlHeight),
                      shape: const StadiumBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
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
