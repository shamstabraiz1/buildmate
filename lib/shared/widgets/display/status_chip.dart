import 'package:flutter/material.dart';

/// Semantic chip for statuses such as active, paid, pending, or overdue.
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    this.status = StatusChipType.neutral,
    this.icon,
    super.key,
  });

  final String label;
  final StatusChipType status;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = switch (status) {
      StatusChipType.success => (
        background: colorScheme.primaryContainer,
        foreground: colorScheme.onPrimaryContainer,
      ),
      StatusChipType.warning => (
        background: colorScheme.tertiaryContainer,
        foreground: colorScheme.onTertiaryContainer,
      ),
      StatusChipType.danger => (
        background: colorScheme.errorContainer,
        foreground: colorScheme.onErrorContainer,
      ),
      StatusChipType.info => (
        background: colorScheme.secondaryContainer,
        foreground: colorScheme.onSecondaryContainer,
      ),
      StatusChipType.neutral => (
        background: colorScheme.surfaceContainerHighest,
        foreground: colorScheme.onSurfaceVariant,
      ),
    };

    return Chip(
      avatar: icon == null
          ? null
          : IconTheme(
              data: IconThemeData(color: colors.foreground),
              child: icon!,
            ),
      label: Text(label),
      backgroundColor: colors.background,
      labelStyle: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(color: colors.foreground),
      side: BorderSide.none,
    );
  }
}

enum StatusChipType { neutral, success, warning, danger, info }
