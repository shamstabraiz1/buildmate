import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../projects/presentation/widgets/project_form_section.dart';
import '../../data/models/vendor_model.dart';
import '../providers/vendor_providers.dart';

class AddVendorScreen extends ConsumerStatefulWidget {
  const AddVendorScreen({this.vendor, super.key});

  final VendorModel? vendor;

  @override
  ConsumerState<AddVendorScreen> createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends ConsumerState<AddVendorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _nameCtrl = TextEditingController(text: widget.vendor?.name);
  late final _contactCtrl =
      TextEditingController(text: widget.vendor?.contactPerson);
  late final _phoneCtrl =
      TextEditingController(text: widget.vendor?.phone);
  late final _emailCtrl =
      TextEditingController(text: widget.vendor?.email);
  late final _addressCtrl =
      TextEditingController(text: widget.vendor?.address);
  late final _notesCtrl =
      TextEditingController(text: widget.vendor?.notes);

  late double _rating = widget.vendor?.rating ?? 0.0;
  bool _isSaving = false;

  bool get _isEdit => widget.vendor != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      if (_isEdit) {
        final updated = widget.vendor!.copyWith(
          name: _nameCtrl.text.trim(),
          contactPerson: _contactCtrl.text.trim().isEmpty
              ? null
              : _contactCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty
              ? null
              : _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty
              ? null
              : _emailCtrl.text.trim(),
          address: _addressCtrl.text.trim().isEmpty
              ? null
              : _addressCtrl.text.trim(),
          rating: _rating,
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
        );
        await ref
            .read(vendorsNotifierProvider.notifier)
            .updateVendor(updated);
      } else {
        final newVendor = VendorModel.create(
          name: _nameCtrl.text.trim(),
          contactPerson: _contactCtrl.text.trim().isEmpty
              ? null
              : _contactCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty
              ? null
              : _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty
              ? null
              : _emailCtrl.text.trim(),
          address: _addressCtrl.text.trim().isEmpty
              ? null
              : _addressCtrl.text.trim(),
          rating: _rating,
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
        );
        await ref
            .read(vendorsNotifierProvider.notifier)
            .addVendor(newVendor);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEdit
                  ? 'Vendor updated successfully.'
                  : '"${_nameCtrl.text.trim()}" added to vendors.',
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
            content: Text('Failed to save vendor: $e'),
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

    return Scaffold(
      appBar: CustomAppBar(
        title: _isEdit ? 'Edit Vendor' : 'Add Vendor',
        subtitle:
            _isEdit ? 'Update vendor details' : 'Register a new supplier',
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
                  // ── Section 1: Company Info ──────────────────────────────
                  ProjectFormSection(
                    title: 'Vendor Info',
                    icon: Icons.business_outlined,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _nameCtrl,
                          labelText: 'Company / Vendor Name *',
                          prefixIcon:
                              const Icon(Icons.storefront_outlined),
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Vendor name is required'
                                  : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _contactCtrl,
                          labelText: 'Contact Person',
                          prefixIcon:
                              const Icon(Icons.person_outline_rounded),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _phoneCtrl,
                          labelText: 'Phone Number',
                          prefixIcon:
                              const Icon(Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+\-\s]')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Section 2: Contact Details ───────────────────────────
                  ProjectFormSection(
                    title: 'Contact Details',
                    icon: Icons.contact_mail_outlined,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _emailCtrl,
                          labelText: 'Email Address',
                          prefixIcon:
                              const Icon(Icons.email_outlined),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(v.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _addressCtrl,
                          labelText: 'Address',
                          prefixIcon:
                              const Icon(Icons.location_on_outlined),
                          textInputAction: TextInputAction.next,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Section 3: Rating & Notes ────────────────────────────
                  ProjectFormSection(
                    title: 'Rating & Notes',
                    icon: Icons.star_border_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vendor Rating',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildRatingSelector(cs),
                        const SizedBox(height: AppSpacing.lg),
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

                  // ── Save / Cancel ────────────────────────────────────────
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
                        _isSaving ? 'Saving…' : _isEdit
                            ? 'Update Vendor'
                            : 'Save Vendor'),
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

  Widget _buildRatingSelector(ColorScheme cs) {
    return Row(
      children: List.generate(5, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () => setState(() => _rating = star.toDouble()),
          child: Padding(
            padding:
                const EdgeInsets.only(right: AppSpacing.xs),
            child: Icon(
              star <= _rating
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: star <= _rating
                  ? const Color(0xFFF2B705)
                  : cs.onSurfaceVariant,
              size: 32,
            ),
          ),
        );
      }),
    );
  }
}
