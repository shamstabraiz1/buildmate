import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_search_bar.dart';
import '../../data/models/project_model.dart';

/// Top filter bar for the Projects screen.
///
/// Renders:
///  - [AppSearchBar] for text search
///  - Horizontal scrollable status [FilterChip] row
///  - Sort [TextButton] that opens a modal bottom sheet
class ProjectsFilterBar extends StatelessWidget {
  const ProjectsFilterBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.activeStatusFilter,
    required this.onStatusFilterChanged,
    required this.activeSortOption,
    required this.onSortChanged,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;

  /// null means "All"
  final ProjectStatus? activeStatusFilter;
  final ValueChanged<ProjectStatus?> onStatusFilterChanged;

  final ProjectSortOption activeSortOption;
  final ValueChanged<ProjectSortOption> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search + sort row
        Row(
          children: [
            Expanded(
              child: AppSearchBar(
                hintText: 'Search projects…',
                controller: searchController,
                onChanged: onSearchChanged,
                onClear: onSearchCleared,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _SortButton(
              active: activeSortOption,
              onChanged: onSortChanged,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        // Status filter chips (horizontal scroll)
        _StatusFilterChips(
          activeFilter: activeStatusFilter,
          onChanged: onStatusFilterChanged,
        ),
      ],
    );
  }
}

// ─── Status filter chips ──────────────────────────────────────────────────────

class _StatusFilterChips extends StatelessWidget {
  const _StatusFilterChips({
    required this.activeFilter,
    required this.onChanged,
  });

  final ProjectStatus? activeFilter;
  final ValueChanged<ProjectStatus?> onChanged;

  static const _filters = [
    (label: 'All', value: null),
    (label: 'Active', value: ProjectStatus.active),
    (label: 'On Hold', value: ProjectStatus.onHold),
    (label: 'Planning', value: ProjectStatus.planning),
    (label: 'Completed', value: ProjectStatus.completed),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((f) {
          final isSelected = activeFilter == f.value;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(f.label),
              selected: isSelected,
              onSelected: (_) => onChanged(f.value),
              showCheckmark: isSelected,
              selectedColor: colorScheme.primaryContainer,
              labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.5)
                    : colorScheme.outlineVariant,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(AppRadius.xxl)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Sort button ──────────────────────────────────────────────────────────────

class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.active,
    required this.onChanged,
  });

  final ProjectSortOption active;
  final ValueChanged<ProjectSortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Sort projects',
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
          onTap: () => _showSortSheet(context),
          child: Container(
            height: AppSpacing.controlHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort_rounded,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Sort',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'Sort Projects',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            ...ProjectModel.sortLabels.entries.map((e) {
              final isActive = e.key == active;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                ),
                leading: Icon(
                  isActive
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isActive ? colorScheme.primary : colorScheme.outline,
                ),
                title: Text(
                  e.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  onChanged(e.key);
                  Navigator.of(ctx).pop();
                },
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
