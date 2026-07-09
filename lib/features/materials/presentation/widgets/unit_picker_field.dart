import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/material_model.dart';

/// A form field that combines a dropdown for common units with
/// an optional custom text input when 'Custom' is selected.
class UnitPickerField extends StatefulWidget {
  const UnitPickerField({
    required this.onChanged,
    this.initialValue,
    this.decoration,
    super.key,
  });

  final String? initialValue;
  final void Function(String unit) onChanged;
  final InputDecoration? decoration;

  @override
  State<UnitPickerField> createState() => _UnitPickerFieldState();
}

class _UnitPickerFieldState extends State<UnitPickerField> {
  late String? _selected;
  final _customCtrl = TextEditingController();
  bool get _isCustom => _selected == 'Custom';

  @override
  void initState() {
    super.initState();
    final init = widget.initialValue;
    if (init != null && MaterialModel.predefinedUnits.contains(init)) {
      _selected = init;
    } else if (init != null && init.isNotEmpty) {
      _selected = 'Custom';
      _customCtrl.text = init;
    } else {
      _selected = null;
    }
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _notify(String? value) {
    if (value == null || value.isEmpty) return;
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selected,
          decoration: widget.decoration ??
              const InputDecoration(
                labelText: 'Unit of Measurement *',
                prefixIcon: Icon(Icons.straighten_outlined),
              ),
          items: MaterialModel.predefinedUnits.map((u) {
            return DropdownMenuItem(
              value: u,
              child: Text(u),
            );
          }).toList(),
          onChanged: (v) {
            setState(() => _selected = v);
            if (v != null && v != 'Custom') {
              _notify(v);
            }
          },
          validator: (v) =>
              v == null || v.isEmpty ? 'Unit is required' : null,
        ),
        if (_isCustom) ...[
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _customCtrl,
            decoration: InputDecoration(
              labelText: 'Custom Unit *',
              hintText: 'e.g., Gallons, Cubic Meters',
              prefixIcon: const Icon(Icons.edit_outlined),
              border: OutlineInputBorder(
                borderRadius:
                    const BorderRadius.all(Radius.circular(AppRadius.md)),
                borderSide: BorderSide(color: cs.outline),
              ),
            ),
            onChanged: _notify,
            validator: (v) =>
                _isCustom && (v == null || v.trim().isEmpty)
                    ? 'Please enter a unit'
                    : null,
          ),
        ],
      ],
    );
  }
}
