import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Primary filled action button for the most important action in a flow.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.tooltip,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isExpanded;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: _ButtonIcon(icon: icon, isLoading: isLoading),
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

class _ButtonIcon extends StatelessWidget {
  const _ButtonIcon({required this.icon, required this.isLoading});

  final Widget? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: AppSpacing.lg,
        child: CircularProgressIndicator(
          strokeWidth: AppSpacing.xxs,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return icon ?? const SizedBox.shrink();
  }
}
