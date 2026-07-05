import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/login_background.dart';
import '../widgets/login_brand_header.dart';
import '../widgets/login_forgot_password.dart';
import '../widgets/login_form.dart';

/// Login screen for BuildMate.
///
/// Adapts between:
///  - **Compact** (< 720 px wide): single-column, scrollable card layout
///  - **Wide**   (≥ 720 px wide): two-column split — branding left, form right
///
/// All fields are UI-only. No authentication logic is implemented here.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
            ),
      child: Scaffold(
        // No AppBar — full-bleed branded experience
        resizeToAvoidBottomInset: true,
        body: LoginBackground(
          child: SafeArea(
            child: _LoginResponsiveLayout(),
          ),
        ),
      ),
    );
  }
}

// ─── Responsive layout dispatcher ────────────────────────────────────────────

class _LoginResponsiveLayout extends StatelessWidget {
  const _LoginResponsiveLayout();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 720
        ? const _WideLoginLayout()
        : const _CompactLoginLayout();
  }
}

// ─── Compact layout ───────────────────────────────────────────────────────────

class _CompactLoginLayout extends StatelessWidget {
  const _CompactLoginLayout();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xxl,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            children: [
              // Brand header
              const LoginBrandHeader(centerAlign: true),

              const SizedBox(height: AppSpacing.xxl),

              // Form card
              _LoginCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    _SectionLabel(text: 'Sign in to your account'),
                    SizedBox(height: AppSpacing.xl),
                    LoginForm(),
                    SizedBox(height: AppSpacing.sm),
                    LoginForgotPassword(),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              const _VersionFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Wide (two-column) layout ─────────────────────────────────────────────────

class _WideLoginLayout extends StatelessWidget {
  const _WideLoginLayout();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxxl,
            vertical: AppSpacing.xxl,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left panel — branding
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: AppSpacing.xxxl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoginBrandHeader(centerAlign: false),
                      SizedBox(height: AppSpacing.xxl),
                      _FeatureHighlights(),
                    ],
                  ),
                ),
              ),

              // Divider
              _VerticalDivider(),

              // Right panel — form card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xxxl),
                  child: _LoginCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        _SectionLabel(text: 'Sign in to your account'),
                        SizedBox(height: AppSpacing.xl),
                        LoginForm(),
                        SizedBox(height: AppSpacing.sm),
                        LoginForgotPassword(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Login card ───────────────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surface.withValues(alpha: 0.92)
            : colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xxl)),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.36 : 0.10),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 80,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─── Feature highlights (wide layout only) ────────────────────────────────────

class _FeatureHighlights extends StatelessWidget {
  const _FeatureHighlights();

  static const _items = [
    (Icons.folder_copy_rounded, 'Multi-project management'),
    (Icons.account_balance_wallet_rounded, 'Complete financial tracking'),
    (Icons.people_alt_rounded, 'Labour & material records'),
    (Icons.bar_chart_rounded, 'Smart reports & analytics'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _items
          .map((item) => _HighlightRow(icon: item.$1, label: item.$2))
          .toList(),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Vertical divider (wide layout) ──────────────────────────────────────────

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 1,
      height: 360,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            colorScheme.outlineVariant.withValues(alpha: 0.6),
            colorScheme.outlineVariant.withValues(alpha: 0.6),
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
    );
  }
}

// ─── Version footer ───────────────────────────────────────────────────────────

class _VersionFooter extends StatelessWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_rounded,
          size: 12,
          color: AppColors.cautionAmber.withValues(alpha: 0.8),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'BuildMate v1.0  ·  Construction Management',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
