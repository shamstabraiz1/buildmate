import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../buttons/app_primary_button.dart';

/// Empty state for lists, filters, and first-run states.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onActionPressed,
    this.maxWidth = 360,
    super.key,
  });

  final String title;
  final String? message;
  final Widget? icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: colorScheme.onSurfaceVariant,
                    size: AppSpacing.xxxl,
                  ),
                  child: icon!,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(
                title,
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionLabel != null && onActionPressed != null) ...[
                const SizedBox(height: AppSpacing.xl),
                AppPrimaryButton(
                  label: actionLabel!,
                  onPressed: onActionPressed,
                  isExpanded: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
