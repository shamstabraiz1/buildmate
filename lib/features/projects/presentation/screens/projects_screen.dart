import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../data/models/project_model.dart';
import '../providers/project_providers.dart';
import '../widgets/project_card.dart';
import '../widgets/projects_filter_bar.dart';
import '../../../dashboard/presentation/widgets/dashboard_bottom_nav.dart';
import 'add_project_screen.dart';
import 'project_details_screen.dart';

/// Projects list screen for BuildMate.
///
/// Features:
///  – Search bar (live filtering by name, client, location)
///  – Status filter chips (All / Active / On Hold / Planning / Completed)
///  – Sort bottom sheet (8 options)
///  – Responsive grid: 1 col on phones, 2 cols on tablets, 3 cols on desktop
///  – FAB to add new project
///  – Empty state when search + filter has no matches
///
/// All data is from SQLite via [projectsNotifierProvider].
class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  // ── State ─────────────────────────────────────────────────────────────────

  final _searchController = TextEditingController();
  String _searchQuery = '';
  ProjectStatus? _statusFilter; // null = All
  ProjectSortOption _sortOption = ProjectSortOption.newest;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtering & sorting ───────────────────────────────────────────────────

  List<ProjectModel> _filtered(List<ProjectModel> baseList) {
    var list = baseList.toList();

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.clientName.toLowerCase().contains(q) ||
            p.location.toLowerCase().contains(q);
      }).toList();
    }

    // Status filter
    if (_statusFilter != null) {
      list = list.where((p) => p.status == _statusFilter).toList();
    }

    // Sort
    switch (_sortOption) {
      case ProjectSortOption.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
      case ProjectSortOption.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
      case ProjectSortOption.budgetHigh:
        list.sort((a, b) => b.budget.compareTo(a.budget));
      case ProjectSortOption.budgetLow:
        list.sort((a, b) => a.budget.compareTo(b.budget));
      case ProjectSortOption.progressHigh:
        list.sort((a, b) => b.progress.compareTo(a.progress));
      case ProjectSortOption.progressLow:
        list.sort((a, b) => a.progress.compareTo(b.progress));
      case ProjectSortOption.newest:
        list.sort((a, b) => b.startDate.compareTo(a.startDate));
      case ProjectSortOption.oldest:
        list.sort((a, b) => a.startDate.compareTo(b.startDate));
    }

    return list;
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  void _onSearchChanged(String q) => setState(() => _searchQuery = q);

  void _onSearchCleared() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _onStatusChanged(ProjectStatus? s) =>
      setState(() => _statusFilter = s);

  void _onSortChanged(ProjectSortOption opt) =>
      setState(() => _sortOption = opt);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    
    final asyncProjects = ref.watch(projectsNotifierProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Projects',
          subtitle: asyncProjects.hasValue ? '${asyncProjects.value!.length} total projects' : 'Loading...',
          showBackButton: false,
          actions: [
            if (asyncProjects.hasValue)
              _ProjectStatsButton(projects: asyncProjects.value!),
          ],
        ),
        bottomNavigationBar: const DashboardBottomNav(
          selectedDestination: DashboardNavDestination.projects,
        ),
        body: asyncProjects.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (projectsList) {
            final filtered = _filtered(projectsList);
            return Column(
              children: [
            // ── Sticky filter bar ──────────────────────────────────────────
            _StickyFilterBar(
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
              onSearchCleared: _onSearchCleared,
              activeStatusFilter: _statusFilter,
              onStatusFilterChanged: _onStatusChanged,
              activeSortOption: _sortOption,
              onSortChanged: _onSortChanged,
            ),

            // ── Results count ──────────────────────────────────────────────
            _ResultsCountBar(
              resultCount: filtered.length,
              total: projectsList.length,
              hasFilters:
                  _searchQuery.isNotEmpty || _statusFilter != null,
            ),

            // ── Project list ───────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyResults(
                      hasFilters:
                          _searchQuery.isNotEmpty || _statusFilter != null,
                      onClear: () {
                        _onSearchCleared();
                        _onStatusChanged(null);
                      },
                    )
                  : _ProjectGrid(projects: filtered),
            ),
          ],
        );
        }),
        floatingActionButton: _AddProjectFab(),
      ),
    );
  }
}

// ─── Sticky filter bar wrapper ─────────────────────────────────────────────────

class _StickyFilterBar extends StatelessWidget {
  const _StickyFilterBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.activeStatusFilter,
    required this.onStatusFilterChanged,
    required this.activeSortOption,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final ProjectStatus? activeStatusFilter;
  final ValueChanged<ProjectStatus?> onStatusFilterChanged;
  final ProjectSortOption activeSortOption;
  final ValueChanged<ProjectSortOption> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: ProjectsFilterBar(
          searchController: searchController,
          onSearchChanged: onSearchChanged,
          onSearchCleared: onSearchCleared,
          activeStatusFilter: activeStatusFilter,
          onStatusFilterChanged: onStatusFilterChanged,
          activeSortOption: activeSortOption,
          onSortChanged: onSortChanged,
        ),
      ),
    );
  }
}

// ─── Results count bar ─────────────────────────────────────────────────────────

class _ResultsCountBar extends StatelessWidget {
  const _ResultsCountBar({
    required this.resultCount,
    required this.total,
    required this.hasFilters,
  });

  final int resultCount;
  final int total;
  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        hasFilters
            ? 'Showing $resultCount of $total projects'
            : '$total projects',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ─── Responsive project grid ───────────────────────────────────────────────────

class _ProjectGrid extends StatelessWidget {
  const _ProjectGrid({required this.projects});

  final List<ProjectModel> projects;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = switch (width) {
      >= 1200 => 3,
      >= 720  => 2,
      _       => 1,
    };

    if (crossAxisCount == 1) {
      // ListView for single-column — better performance on phones
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxxl + AppSpacing.xxl, // FAB clearance
        ),
        itemCount: projects.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) => ProjectCard(
          project: projects[i],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProjectDetailsScreen(projectId: projects[i].id),
              ),
            );
          },
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxxl + AppSpacing.xxl,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: crossAxisCount == 3 ? 0.75 : 0.80,
      ),
      itemCount: projects.length,
      itemBuilder: (context, i) => ProjectCard(
        project: projects[i],
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProjectDetailsScreen(projectId: projects[i].id),
            ),
          );
        },
      ),
    );
  }
}

// ─── Empty results state ───────────────────────────────────────────────────────

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({
    required this.hasFilters,
    required this.onClear,
  });

  final bool hasFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: const Icon(Icons.folder_off_rounded),
      title: hasFilters ? 'No projects found' : 'No projects yet',
      message: hasFilters
          ? 'Try adjusting your search or filters.'
          : 'Tap the + button to create your first project.',
      actionLabel: hasFilters ? 'Clear filters' : null,
      onActionPressed: hasFilters ? onClear : null,
    );
  }
}

// ─── Header stats button ───────────────────────────────────────────────────────

class _ProjectStatsButton extends StatelessWidget {
  const _ProjectStatsButton({required this.projects});

  final List<ProjectModel> projects;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final active = projects
        .where((p) => p.status == ProjectStatus.active)
        .length;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.65),
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xxl)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.successGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$active Active',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── FAB ──────────────────────────────────────────────────────────────────────

class _AddProjectFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AddProjectScreen(),
          ),
        );
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('New Project'),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.xxl)),
      ),
    );
  }
}
