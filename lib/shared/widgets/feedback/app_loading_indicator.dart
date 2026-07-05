import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Centered loading indicator with optional message.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({this.message, this.isCentered = true, super.key});

  final String? message;
  final bool isCentered;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    return isCentered ? Center(child: content) : content;
  }
}
