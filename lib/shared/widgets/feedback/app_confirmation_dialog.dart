import 'package:flutter/material.dart';

/// Reusable confirmation dialog for non-destructive decisions.
class AppConfirmationDialog extends StatelessWidget {
  const AppConfirmationDialog({
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.icon,
    this.onConfirm,
    this.onCancel,
    super.key,
  });

  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final Widget? icon;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return AlertDialog(
      icon: icon,
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: Text(cancelLabel ?? localizations.cancelButtonLabel),
        ),
        FilledButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
          child: Text(confirmLabel ?? localizations.okButtonLabel),
        ),
      ],
    );
  }
}
