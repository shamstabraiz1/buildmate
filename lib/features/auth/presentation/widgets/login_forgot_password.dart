import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// A subtle "Forgot password?" link button, aligned to the end of the form.
///
/// Tap handler is a stub — wire to your password-reset route when ready.
class LoginForgotPassword extends StatelessWidget {
  const LoginForgotPassword({super.key});

  void _handleForgotPassword(BuildContext context) {
    // TODO: Navigate to the forgot-password / reset flow
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _handleForgotPassword(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: colorScheme.primary,
        ),
        child: Text(
          'Forgot password?',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
