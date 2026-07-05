import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/display/section_title.dart';
import '../data/dashboard_dummy_data.dart';
import '../widgets/dashboard_activity_tile.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/dashboard_expense_chart.dart';
import '../widgets/dashboard_greeting_header.dart';
import '../widgets/dashboard_project_progress.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_summary_card.dart';

/// The BuildMate Dashboard — the primary, best-looking screen in the app.
///
/// Layout:
///  ─ Greeting header (sticky-like, in SliverAppBar)
///  ─ Scrollable body:
///     • Summary cards (2×2 grid)
///     • Quick actions
///     • Recent activities
///     • Expense overview (bar chart)
///     • Project progress
///  ─ Bottom navigation
///  ─ FAB (Add Expense)
///
/// All data is dummy; no business logic or SQLite.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardNavDestination _selectedNav = DashboardNavDestination.dashboard;

  void _onNavSelected(DashboardNavDestination dest) =>
      setState(() => _selectedNav = dest);

  void _onQuickAction(int index) {
    // TODO: navigate to the respective feature
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: colorScheme.surface,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: colorScheme.surface,
            ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: _DashboardBody(onQuickAction: _onQuickAction),
        bottomNavigationBar: DashboardBottomNav(
          selectedDestination: _selectedNav,
          onDestinationSelected: _onNavSelected,
        ),
        floatingActionButton: _DashboardFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

// ─── Main scrollable body ─────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.onQuickAction});

  final ValueChanged<int> onQuickAction;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 720;

    return isWide
        ? _WideDashboardLayout(onQuickAction: onQuickAction)
        : _CompactDashboardLayout(onQuickAction: onQuickAction);
  }
}

// ─── Compact layout (phones) ──────────────────────────────────────────────────

class _CompactDashboardLayout extends StatelessWidget {
  const _CompactDashboardLayout({required this.onQuickAction});

  final ValueChanged<int> onQuickAction;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Greeting header ─────────────────────────────────────────────────
        const SliverToBoxAdapter(child: _DashboardHeaderBanner()),

        // ── Content body ────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: AppSpacing.lg),

              // Summary cards grid
              _SummarySectionCompact(),

              const SizedBox(height: AppSpacing.xxl),

              // Quick actions
              SectionTitle(
                title: 'Quick Actions',
                subtitle: 'Common tasks at a glance',
              ),
              DashboardQuickActions(
                actions: DashboardDummyData.quickActions,
                onActionTap: onQuickAction,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Recent activities
              SectionTitle(
                title: 'Recent Activity',
                subtitle: 'Last 6 transactions',
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('See All'),
                ),
              ),
              _ActivitiesCard(),

              const SizedBox(height: AppSpacing.xxl),

              // Expense overview
              DashboardExpenseChart(points: DashboardDummyData.expenseChart),

              const SizedBox(height: AppSpacing.xxl),

              // Project progress
              SectionTitle(
                title: 'Project Progress',
                subtitle: '${DashboardDummyData.projects.length} active projects',
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ),
              DashboardProjectProgress(
                projects: DashboardDummyData.projects,
              ),

              // Bottom spacing for FAB
              const SizedBox(height: AppSpacing.xxxl + AppSpacing.xxl),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─── Wide layout (tablets / desktop) ─────────────────────────────────────────

class _WideDashboardLayout extends StatelessWidget {
  const _WideDashboardLayout({required this.onQuickAction});

  final ValueChanged<int> onQuickAction;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _DashboardHeaderBanner()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left column ─────────────────────────────────────────────
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _SummarySectionCompact(),
                      const SizedBox(height: AppSpacing.xxl),

                      SectionTitle(title: 'Quick Actions'),
                      DashboardQuickActions(
                        actions: DashboardDummyData.quickActions,
                        onActionTap: onQuickAction,
                      ),

                      const SizedBox(height: AppSpacing.xxl),
                      DashboardExpenseChart(
                        points: DashboardDummyData.expenseChart,
                      ),

                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.xl),

                // ── Right column ─────────────────────────────────────────────
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      SectionTitle(
                        title: 'Recent Activity',
                        trailing: TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                      ),
                      _ActivitiesCard(),

                      const SizedBox(height: AppSpacing.xxl),

                      SectionTitle(
                        title: 'Project Progress',
                        trailing: TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ),
                      DashboardProjectProgress(
                        projects: DashboardDummyData.projects,
                      ),

                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Header banner (gradient background + greeting) ───────────────────────────

class _DashboardHeaderBanner extends StatelessWidget {
  const _DashboardHeaderBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.blueprintNavyDark,
                  colorScheme.surface,
                ]
              : [
                  colorScheme.primaryContainer.withValues(alpha: 0.38),
                  colorScheme.surface,
                ],
        ),
      ),
      child: CustomPaint(
        painter: _HeaderPatternPainter(colorScheme: colorScheme),
        child: const DashboardGreetingHeader(),
      ),
    );
  }
}

// ─── Subtle blueprint pattern for the header ──────────────────────────────────

class _HeaderPatternPainter extends CustomPainter {
  const _HeaderPatternPainter({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    // Horizontal lines
    for (var y = 16.0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (var x = 16.0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Corner arc accent
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width, 0),
        radius: size.width * 0.35,
      ),
      1.57,
      1.57,
      false,
      Paint()
        ..color = colorScheme.primary.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _HeaderPatternPainter old) =>
      old.colorScheme != colorScheme;
}

// ─── Summary cards 2×2 grid ───────────────────────────────────────────────────

class _SummarySectionCompact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cards = DashboardDummyData.summaryCards;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.95,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => DashboardSummaryCard(
        data: cards[index],
        onTap: () {},
      ),
    );
  }
}

// ─── Activities card container ────────────────────────────────────────────────

class _ActivitiesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.28 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ...DashboardDummyData.activities.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                DashboardActivityTile(item: item, onTap: () {}),
                if (i < DashboardDummyData.activities.length - 1)
                  Divider(
                    height: 1,
                    indent: AppSpacing.lg + 44 + AppSpacing.md,
                    endIndent: AppSpacing.lg,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── FAB ─────────────────────────────────────────────────────────────────────

class _DashboardFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: () {
        // TODO: Open Add Expense bottom sheet
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add Expense'),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.xxl)),
      ),
    );
  }
}
