import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/onboarding_bottom_bar.dart';
import '../widgets/onboarding_page.dart';

/// Onboarding screen for BuildMate.
///
/// Presents three swipeable feature introduction pages using a [PageView],
/// a smooth page indicator, and Skip / Next / Get Started controls.
///
/// Navigation is intentionally not implemented — wire [_handleSkip] and
/// [_handleGetStarted] to your router when integrating.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  // ── State ────────────────────────────────────────────────────────────────

  late final PageController _pageController;
  double _currentPage = 0;

  static const _pages = [
    OnboardingPageData(
      title: 'Manage Construction Projects',
      description:
          'Create and manage multiple construction projects with complete financial tracking.',
      pageIndex: 0,
    ),
    OnboardingPageData(
      title: 'Track Labour & Materials',
      description:
          'Record labour payments, material purchases, and daily expenses quickly.',
      pageIndex: 1,
    ),
    OnboardingPageData(
      title: 'Smart Reports & Analytics',
      description:
          'Generate project reports, expense summaries, and financial insights.',
      pageIndex: 2,
    ),
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageScroll);
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_onPageScroll)
      ..dispose();
    super.dispose();
  }

  // ── Callbacks ─────────────────────────────────────────────────────────────

  void _onPageScroll() {
    if (!mounted) return;
    setState(() {
      _currentPage = _pageController.page ?? 0;
    });
  }

  void _handleNext() {
    final nextPage = (_currentPage.round() + 1).clamp(0, _pages.length - 1);
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _handleSkip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Wire to your router's navigation call, e.g. `context.go(AppRoutes.login)`.
  void _handleGetStarted() {
    // TODO: Navigate to the next screen
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Use edge-to-edge rendering for a premium feel
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemUiStyle(context),
      child: Scaffold(
        body: Column(
          children: [
            // ── Page view fills all available space ─────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index]);
                },
              ),
            ),

            // ── Bottom action bar ───────────────────────────────────────────
            OnboardingBottomBar(
              page: _currentPage,
              pageCount: _pages.length,
              onSkip: _handleSkip,
              onNext: _handleNext,
              onGetStarted: _handleGetStarted,
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  SystemUiOverlayStyle _systemUiStyle(BuildContext context) {
    final isDark =
        Theme.of(context).colorScheme.brightness == Brightness.dark;
    return isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          );
  }
}
