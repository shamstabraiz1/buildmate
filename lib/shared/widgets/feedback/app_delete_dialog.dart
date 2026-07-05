import 'package:flutter/material.dart';

/// Destructive confirmation dialog for delete actions.
class AppDeleteDialog extends StatelessWidget {
  const AppDeleteDialog({
    required this.title,
    required this.message,
    this.deleteLabel = 'Delete',
    this.cancelLabel,
    this.onDelete,
    this.onCancel,
    super.key,
  });

  final String title;
  final String message;
  final String deleteLabel;
  final String? cancelLabel;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = MaterialLocalizations.of(context);

    return AlertDialog(
      icon: Icon(Icons.delete_outline, color: colorScheme.error),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: Text(cancelLabel ?? localizations.cancelButtonLabel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          onPressed: onDelete ?? () => Navigator.of(context).pop(true),
          child: Text(deleteLabel),
        ),
      ],
    );
  }
}
