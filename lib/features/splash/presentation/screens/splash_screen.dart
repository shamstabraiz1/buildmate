import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: _SplashFadeIn(
          child: _SplashContent(),
        ),
      ),
    );
  }
}

class _SplashFadeIn extends StatefulWidget {
  const _SplashFadeIn({required this.child});

  final Widget child;

  @override
  State<_SplashFadeIn> createState() => _SplashFadeInState();
}

class _SplashFadeInState extends State<_SplashFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go(AppRoutes.dashboard);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    final constraints = MediaQuery.sizeOf(context);
    final isWide = constraints.width >= 720;
    final horizontalPadding = isWide ? AppSpacing.xxxl : AppSpacing.xl;
    final maxContentWidth = isWide ? 960.0 : 520.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _SplashBackgroundGradient.of(context),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: AppSpacing.xxl,
            ),
            child: isWide
                ? const _WideSplashLayout()
                : const _CompactSplashLayout(),
          ),
        ),
      ),
    );
  }
}

class _WideSplashLayout extends StatelessWidget {
  const _WideSplashLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _BrandBlock(alignment: CrossAxisAlignment.start)),
            SizedBox(width: AppSpacing.xxxl),
            Expanded(child: _ConstructionIllustrationPlaceholder()),
          ],
        ),
        const Spacer(),
        AppLoadingIndicator(
          message: 'Preparing your workspace',
          isCentered: false,
        ),
      ],
    );
  }
}

class _CompactSplashLayout extends StatelessWidget {
  const _CompactSplashLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        const _BrandBlock(alignment: CrossAxisAlignment.center),
        const SizedBox(height: AppSpacing.xxxl),
        const _ConstructionIllustrationPlaceholder(),
        const Spacer(),
        AppLoadingIndicator(
          message: 'Preparing your workspace',
          isCentered: false,
        ),
      ],
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock({required this.alignment});

  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final textAlign = alignment == CrossAxisAlignment.center
        ? TextAlign.center
        : TextAlign.start;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        const _AppLogoPlaceholder(),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'BuildMate',
          textAlign: textAlign,
          style: theme.textTheme.displaySmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Plan, track, and deliver construction work.',
          textAlign: textAlign,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _AppLogoPlaceholder extends StatelessWidget {
  const _AppLogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'BuildMate app logo placeholder',
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: AppRadius.dialogBorder,
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.16),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Icon(
          Icons.construction_rounded,
          color: colorScheme.onPrimaryContainer,
          size: 44,
        ),
      ),
    );
  }
}

class _ConstructionIllustrationPlaceholder extends StatelessWidget {
  const _ConstructionIllustrationPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Construction illustration placeholder',
      child: AspectRatio(
        aspectRatio: 1.2,
        child: CustomPaint(
          painter: _ConstructionIllustrationPainter(colorScheme),
          child: Center(
            child: Icon(
              Icons.apartment_rounded,
              color: colorScheme.primary,
              size: 56,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConstructionIllustrationPainter extends CustomPainter {
  const _ConstructionIllustrationPainter(this.colorScheme);

  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final beamPaint = Paint()
      ..color = colorScheme.secondaryContainer
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final accentPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;
    final surfacePaint = Paint()
      ..color = colorScheme.surfaceContainerHighest
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = colorScheme.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final radius = Radius.circular(AppRadius.lg);
    final structure = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.17,
        size.height * 0.22,
        size.width * 0.66,
        size.height * 0.58,
      ),
      radius,
    );

    canvas.drawRRect(structure, surfacePaint);
    canvas.drawRRect(structure, outlinePaint);

    for (var i = 0; i < 4; i++) {
      final x = size.width * (0.29 + i * 0.14);
      canvas.drawLine(
        Offset(x, size.height * 0.35),
        Offset(x, size.height * 0.67),
        beamPaint,
      );
    }

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.73),
      Offset(size.width * 0.8, size.height * 0.73),
      beamPaint,
    );

    final cranePath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.16)
      ..lineTo(size.width * 0.68, size.height * 0.16)
      ..lineTo(size.width * 0.68, size.height * 0.22)
      ..lineTo(size.width * 0.12, size.height * 0.22)
      ..close();
    canvas.drawPath(cranePath, accentPaint);

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.16,
        size.height * 0.22,
        size.width * 0.05,
        size.height * 0.52,
      ),
      accentPaint,
    );

    final hookPaint = Paint()
      ..color = colorScheme.tertiary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.22),
      Offset(size.width * 0.58, size.height * 0.34),
      hookPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.59, size.height * 0.36),
        radius: 8,
      ),
      1.3,
      3.4,
      false,
      hookPaint,
    );

    final groundPaint = Paint()
      ..color = AppColors.cautionAmber.withValues(alpha: 0.65)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.85),
      Offset(size.width * 0.88, size.height * 0.85),
      groundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ConstructionIllustrationPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme;
  }
}

class _SplashBackgroundGradient {
  const _SplashBackgroundGradient._();

  static LinearGradient of(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.surface,
        isDark ? AppColors.blueprintNavyDark : AppColors.lightBackground,
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
      ],
    );
  }
}
