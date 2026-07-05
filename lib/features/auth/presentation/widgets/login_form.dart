import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buildmate_widgets.dart';

/// The complete login form: username, password (with show/hide toggle),
/// remember-me checkbox, and the primary Login action button.
///
/// All form state is managed internally; no authentication logic is included.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // ── Controllers & form key ───────────────────────────────────────────────

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // ── UI state ─────────────────────────────────────────────────────────────

  bool _obscurePassword = true;
  bool _rememberMe = false;
  // ignore: unused_field
  final bool _isLoading = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  /// Validates the form. Replace the body with real auth logic when ready.
  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: Trigger authentication use-case / provider
  }

  void _togglePasswordVisibility() =>
      setState(() => _obscurePassword = !_obscurePassword);

  void _toggleRememberMe(bool? value) =>
      setState(() => _rememberMe = value ?? false);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Username field
          _UsernameField(controller: _usernameController),

          const SizedBox(height: AppSpacing.lg),

          // Password field
          _PasswordField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            onToggleVisibility: _togglePasswordVisibility,
          ),

          const SizedBox(height: AppSpacing.md),

          // Remember me
          _RememberMeRow(
            value: _rememberMe,
            onChanged: _toggleRememberMe,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Login button
          AppPrimaryButton(
            label: 'Login',
            onPressed: _handleLogin,
            icon: const Icon(Icons.login_rounded, size: 20),
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

// ─── Username field ────────────────────────────────────────────────────────────

class _UsernameField extends StatelessWidget {
  const _UsernameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      labelText: 'Username',
      hintText: 'Enter your username',
      prefixIcon: const Icon(Icons.person_outline_rounded),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your username';
        }
        return null;
      },
    );
  }
}

// ─── Password field ────────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      labelText: 'Password',
      hintText: 'Enter your password',
      obscureText: obscureText,
      prefixIcon: const Icon(Icons.lock_outline_rounded),
      suffixIcon: _PasswordVisibilityToggle(
        obscureText: obscureText,
        onToggle: onToggleVisibility,
      ),
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
}

// ─── Show / Hide password toggle icon button ───────────────────────────────────

class _PasswordVisibilityToggle extends StatelessWidget {
  const _PasswordVisibilityToggle({
    required this.obscureText,
    required this.onToggle,
  });

  final bool obscureText;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: obscureText ? 'Show password' : 'Hide password',
      button: true,
      child: IconButton(
        icon: Icon(
          obscureText
              ? Icons.visibility_rounded
              : Icons.visibility_off_rounded,
        ),
        onPressed: onToggle,
        tooltip: obscureText ? 'Show password' : 'Hide password',
      ),
    );
  }
}

// ─── Remember me row ───────────────────────────────────────────────────────────

class _RememberMeRow extends StatelessWidget {
  const _RememberMeRow({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Remember me',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
