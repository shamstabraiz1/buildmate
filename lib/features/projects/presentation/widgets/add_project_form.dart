import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../data/models/project_model.dart';
import 'project_date_field.dart';
import 'project_form_section.dart';

/// The complete Add Project form.
///
/// Manages all field state internally and exposes [onSave] / [onCancel]
/// callbacks. No database interaction — all values are kept in memory.
///
/// Fields:
///  – Project Name, Client Name, Client Phone, Location (Project Info)
///  – Budget                                            (Financial)
///  – Start Date, Expected Completion                   (Timeline)
///  – Description                                       (Details)
class AddProjectForm extends StatefulWidget {
  const AddProjectForm({
    required this.onSave,
    required this.onCancel,
    this.project,
    super.key,
  });

  /// Called with a map of field values when the form is valid and saved.
  final ValueChanged<Map<String, dynamic>> onSave;
  final VoidCallback onCancel;
  final ProjectModel? project;

  @override
  State<AddProjectForm> createState() => _AddProjectFormState();
}

class _AddProjectFormState extends State<AddProjectForm> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ───────────────────────────────────────────────────────────
  late final TextEditingController _nameCtrl;
  late final TextEditingController _clientNameCtrl;
  late final TextEditingController _clientPhoneCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _budgetCtrl;
  late final TextEditingController _descCtrl;

  // ── Date state ────────────────────────────────────────────────────────────
  DateTime? _startDate;
  DateTime? _completionDate;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _clientNameCtrl = TextEditingController(text: p?.clientName ?? '');
    _clientPhoneCtrl = TextEditingController(text: '');
    _locationCtrl = TextEditingController(text: p?.location ?? '');
    _budgetCtrl = TextEditingController(text: p?.budget.toStringAsFixed(0) ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _startDate = p?.startDate;
    _completionDate = p?.endDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _clientNameCtrl.dispose();
    _clientPhoneCtrl.dispose();
    _locationCtrl.dispose();
    _budgetCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Validation helpers ────────────────────────────────────────────────────
  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Enter a valid 10-digit phone number';
    return null;
  }

  String? _validateBudget(String? v) {
    if (v == null || v.trim().isEmpty) return 'Budget is required';
    final n = double.tryParse(v.replaceAll(',', ''));
    if (n == null || n <= 0) return 'Enter a valid budget amount';
    return null;
  }

  String? _validateStartDate(String? _) =>
      _startDate == null ? 'Start date is required' : null;

  String? _validateCompletionDate(String? _) {
    if (_completionDate == null) return 'Completion date is required';
    if (_startDate != null && _completionDate!.isBefore(_startDate!)) {
      return 'Must be after start date';
    }
    return null;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _handleSave() {
    // Trigger date field validation manually
    setState(() {}); // rebuild to show date errors
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _completionDate == null) return;

    widget.onSave({
      'name':           _nameCtrl.text.trim(),
      'clientName':     _clientNameCtrl.text.trim(),
      'clientPhone':    _clientPhoneCtrl.text.trim(),
      'location':       _locationCtrl.text.trim(),
      'budget':         double.parse(_budgetCtrl.text.replaceAll(',', '')),
      'startDate':      _startDate,
      'completionDate': _completionDate,
      'description':    _descCtrl.text.trim(),
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Project Info ─────────────────────────────────────────────────
          ProjectFormSection(
            title: 'Project Info',
            icon: Icons.apartment_rounded,
            subtitle: 'Basic details about the project',
            child: Column(
              children: [
                AppTextField(
                  controller: _nameCtrl,
                  labelText: 'Project Name *',
                  hintText: 'e.g. Skyline Tower Block B',
                  prefixIcon: const Icon(Icons.drive_file_rename_outline_rounded),
                  textInputAction: TextInputAction.next,
                  validator: (v) => _required(v, 'Project name'),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _locationCtrl,
                  labelText: 'Location *',
                  hintText: 'e.g. Andheri West, Mumbai',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  textInputAction: TextInputAction.next,
                  validator: (v) => _required(v, 'Location'),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ── Client Info ──────────────────────────────────────────────────
          ProjectFormSection(
            title: 'Client Details',
            icon: Icons.person_outline_rounded,
            subtitle: 'Who is this project for?',
            child: Column(
              children: [
                AppTextField(
                  controller: _clientNameCtrl,
                  labelText: 'Client Name *',
                  hintText: 'e.g. Mehta Developers Pvt. Ltd.',
                  prefixIcon: const Icon(Icons.business_rounded),
                  textInputAction: TextInputAction.next,
                  validator: (v) => _required(v, 'Client name'),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _clientPhoneCtrl,
                  labelText: 'Client Phone *',
                  hintText: 'e.g. 9876543210',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                  validator: _validatePhone,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ── Financial ────────────────────────────────────────────────────
          ProjectFormSection(
            title: 'Budget',
            icon: Icons.account_balance_wallet_rounded,
            subtitle: 'Total approved project budget',
            child: _BudgetField(
              controller: _budgetCtrl,
              validator: _validateBudget,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ── Timeline ─────────────────────────────────────────────────────
          ProjectFormSection(
            title: 'Timeline',
            icon: Icons.calendar_today_rounded,
            subtitle: 'Project start and expected end dates',
            child: Column(
              children: [
                ProjectDateField(
                  labelText: 'Start Date *',
                  hintText: 'Select start date',
                  prefixIcon: const Icon(Icons.play_circle_outline_rounded),
                  selectedDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  validator: _validateStartDate,
                  onDateSelected: (d) => setState(() => _startDate = d),
                ),
                const SizedBox(height: AppSpacing.lg),
                ProjectDateField(
                  labelText: 'Expected Completion *',
                  hintText: 'Select completion date',
                  prefixIcon: const Icon(Icons.flag_outlined),
                  selectedDate: _completionDate,
                  firstDate: _startDate ?? DateTime(2020),
                  lastDate: DateTime(2035),
                  validator: _validateCompletionDate,
                  onDateSelected: (d) => setState(() => _completionDate = d),
                ),
                if (_startDate != null && _completionDate != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _DurationBadge(start: _startDate!, end: _completionDate!),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ── Description ──────────────────────────────────────────────────
          ProjectFormSection(
            title: 'Description',
            icon: Icons.notes_rounded,
            subtitle: 'Optional — scope, notes, or special instructions',
            child: AppTextField(
              controller: _descCtrl,
              labelText: 'Project Description',
              hintText:
                  'Describe the scope, special requirements, or any notes…',
              prefixIcon: const Icon(Icons.description_outlined),
              textInputAction: TextInputAction.newline,
              maxLines: 5,
              minLines: 3,
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // ── Action buttons ───────────────────────────────────────────────
          _FormActionButtons(
            onSave: _handleSave,
            onCancel: widget.onCancel,
          ),
        ],
      ),
    );
  }
}

// ─── Budget field with currency prefix ───────────────────────────────────────

class _BudgetField extends StatelessWidget {
  const _BudgetField({
    required this.controller,
    required this.validator,
  });

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return AppTextField(
      controller: controller,
      labelText: 'Budget Amount (₹) *',
      hintText: 'e.g. 2500000',
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d,]')),
        LengthLimitingTextInputFormatter(12),
      ],
      prefixIcon: Container(
        margin: const EdgeInsets.all(AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.65),
          borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.xs)),
        ),
        child: Text(
          '₹',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      validator: validator,
      helperText: 'Enter amount in Indian Rupees',
    );
  }
}

// ─── Calculated duration badge ────────────────────────────────────────────────

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final days = end.difference(start).inDays;
    if (days <= 0) return const SizedBox.shrink();

    final months = (days / 30.44).round();
    final label =
        months >= 2 ? 'Duration: ~$months months' : 'Duration: $days days';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.xxl)),
        border: Border.all(
          color: AppColors.successGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timelapse_rounded,
            size: 14,
            color: AppColors.successGreen,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.successGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form action buttons ──────────────────────────────────────────────────────

class _FormActionButtons extends StatelessWidget {
  const _FormActionButtons({
    required this.onSave,
    required this.onCancel,
  });

  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 600;

    final saveBtn = FilledButton.icon(
      onPressed: onSave,
      icon: const Icon(Icons.check_circle_outline_rounded),
      label: const Text('Save Project'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSpacing.controlHeight),
        shape: const StadiumBorder(),
      ),
    );

    final cancelBtn = OutlinedButton(
      onPressed: onCancel,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSpacing.controlHeight),
        shape: const StadiumBorder(),
      ),
      child: const Text('Cancel'),
    );

    if (isWide) {
      return Row(
        children: [
          Expanded(child: cancelBtn),
          const SizedBox(width: AppSpacing.md),
          Expanded(flex: 2, child: saveBtn),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        saveBtn,
        const SizedBox(height: AppSpacing.md),
        cancelBtn,
      ],
    );
  }
}
