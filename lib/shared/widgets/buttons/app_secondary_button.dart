import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Secondary tonal button for supportive actions that are not destructive.
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isExpanded = true,
    this.tooltip,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isExpanded;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: icon ?? const SizedBox.shrink(),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSpacing.controlHeight),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.buttonBorder,
        ),
      ),
    );

    final child = isExpanded
        ? SizedBox(width: double.infinity, child: button)
        : button;

    return tooltip == null ? child : Tooltip(message: tooltip!, child: child);
  }
}
