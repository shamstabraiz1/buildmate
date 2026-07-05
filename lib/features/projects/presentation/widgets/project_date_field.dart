import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// A tappable date-picker field that looks like an [AppTextField].
///
/// Tapping it opens [showDatePicker] and calls [onDateSelected]
/// with the chosen [DateTime]. The field is read-only; keyboard input
/// is disabled. Displays [hintText] when no date is selected.
class ProjectDateField extends StatelessWidget {
  const ProjectDateField({
    required this.labelText,
    required this.onDateSelected,
    this.selectedDate,
    this.hintText,
    this.prefixIcon,
    this.firstDate,
    this.lastDate,
    this.validator,
    this.helperText,
    super.key,
  });

  final String labelText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? hintText;
  final Widget? prefixIcon;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final FormFieldValidator<String>? validator;
  final String? helperText;

  String? get _displayValue {
    if (selectedDate == null) return null;
    final d = selectedDate!;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          datePickerTheme: DatePickerThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.xxl)),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final hasValue = selectedDate != null;

    return FormField<String>(
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _pickDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: _displayValue ?? '',
                  ),
                  decoration: InputDecoration(
                    labelText: labelText,
                    hintText: hintText ?? 'Select date',
                    prefixIcon: prefixIcon,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        size: 20,
                        color: hasValue
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    errorText: state.errorText,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hasValue
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (helperText != null && state.errorText == null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  helperText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
