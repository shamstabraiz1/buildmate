import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Standard bottom sheet container with optional title, actions, and drag handle.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    required this.child,
    this.title,
    this.subtitle,
    this.actions,
    this.showDragHandle = true,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    super.key,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showDragHandle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ClipRRect(
        borderRadius: AppRadius.bottomSheetBorder,
        child: Material(
          color: colorScheme.surface,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDragHandle)
                  Center(
                    child: Container(
                      width: AppSpacing.xxxl,
                      height: AppSpacing.xs,
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: AppRadius.snackbarBorder,
                      ),
                    ),
                  ),
                if (title != null || actions != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title!, style: textTheme.titleLarge),
                              if (subtitle != null) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  subtitle!,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ...?actions,
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows a modal [AppBottomSheet] with the BuildMate sheet treatment.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  String? subtitle,
  List<Widget>? actions,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    builder: (context) {
      return AppBottomSheet(
        title: title,
        subtitle: subtitle,
        actions: actions,
        child: child,
      );
    },
  );
}
