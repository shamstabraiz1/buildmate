import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/inputs/app_search_bar.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../vendors/presentation/screens/vendors_screen.dart';
import '../../data/models/material_model.dart';
import '../providers/material_providers.dart';
import '../widgets/low_stock_banner.dart';
import '../widgets/material_card.dart';
import 'add_material_screen.dart';
import 'material_details_screen.dart';

class MaterialsScreen extends ConsumerStatefulWidget {
  const MaterialsScreen({super.key});

  @override
  ConsumerState<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends ConsumerState<MaterialsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    final filteredMaterials = ref.watch(filteredMaterialsProvider);
    final materialsAsync = ref.watch(materialsNotifierProvider);
    final projectsAsync = ref.watch(projectsNotifierProvider);
    final lowStockCount = ref.watch(lowStockCountProvider);
    final searchQuery = ref.watch(materialSearchQueryProvider);
    final categoryFilter = ref.watch(materialCategoryFilterProvider);
    final projectFilter = ref.watch(materialProjectFilterProvider);
    final sortOption = ref.watch(materialSortOptionProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
              .copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Material Inventory',
          subtitle: 'Manage stock and suppliers',
          showBackButton: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.sort_rounded),
              tooltip: 'Sort',
              onPressed: () => _showSortModal(context, sortOption),
            ),
            IconButton(
              icon: const Icon(Icons.local_shipping_outlined),
              tooltip: 'Vendors',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const VendorsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddMaterialScreen()),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Material'),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.xxl)),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search & Filters ──────────────────────────────────────────
            Material(
              color: cs.surface,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    AppSearchBar(
                      hintText: 'Search materials…',
                      controller: _searchCtrl,
                      onChanged: (v) {
                        ref
                            .read(materialSearchQueryProvider.notifier)
                            .update(v);
                      },
                      onClear: () {
                        _searchCtrl.clear();
                        ref
                            .read(materialSearchQueryProvider.notifier)
                            .update('');
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Category chips
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryChip(
                            context, 'All', null, categoryFilter, cs),
                          ...MaterialCategory.values
                              .where(
                                  (c) => c != MaterialCategory.custom)
                              .map(
                                (cat) => _buildCategoryChip(
                                  context,
                                  MaterialModel.categoryLabels[cat] ??
                                      cat.name,
                                  cat,
                                  categoryFilter,
                                  cs,
                                ),
                              ),
                        ],
                      ),
                    ),

                    // Project filter row (shown when projects exist)
                    if (projectsAsync.hasValue &&
                        projectsAsync.value!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      SizedBox(
                        height: 32,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildProjectChip(context, 'All Projects',
                                null, projectFilter, cs),
                            ...projectsAsync.value!.map(
                              (p) => _buildProjectChip(context, p.name,
                                  p.id, projectFilter, cs),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Low Stock Banner ──────────────────────────────────────────
            LowStockBanner(
              count: lowStockCount,
              onTap: () {
                ref.read(materialSortOptionProvider.notifier).update(
                    MaterialSortOption.lowStockFirst);
              },
            ),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: materialsAsync.when(
                data: (_) {
                  if (filteredMaterials.isEmpty) {
                    final hasFilters = searchQuery.isNotEmpty ||
                        categoryFilter != null ||
                        projectFilter != null;
                    return EmptyStateWidget(
                      icon:
                          const Icon(Icons.inventory_2_outlined, size: 64),
                      title: 'No materials found',
                      message: hasFilters
                          ? 'Try adjusting your search or filters.'
                          : 'Add your first material to begin tracking stock.',
                      actionLabel:
                          hasFilters ? 'Clear Filters' : null,
                      onActionPressed: hasFilters
                          ? () {
                              _searchCtrl.clear();
                              ref
                                  .read(
                                      materialSearchQueryProvider.notifier)
                                  .update('');
                              ref
                                  .read(
                                      materialCategoryFilterProvider
                                          .notifier)
                                  .update(null);
                              ref
                                  .read(
                                      materialProjectFilterProvider
                                          .notifier)
                                  .update(null);
                            }
                          : null,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.xxxl * 2,
                    ),
                    itemCount: filteredMaterials.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final mat = filteredMaterials[i];
                      return MaterialCard(
                        material: mat,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  MaterialDetailsScreen(materialId: mat.id),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: AppLoadingIndicator()),
                error: (err, _) => Center(
                  child: Text('Error: $err',
                      textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    MaterialCategory? cat,
    MaterialCategory? current,
    ColorScheme cs,
  ) {
    final selected = current == cat;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          ref.read(materialCategoryFilterProvider.notifier).update(cat);
        },
        showCheckmark: selected,
        selectedColor: cs.primaryContainer,
        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color:
                  selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
            ),
        side: BorderSide(
          color: selected
              ? cs.primary.withValues(alpha: 0.5)
              : cs.outlineVariant,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.xxl)),
        ),
      ),
    );
  }

  Widget _buildProjectChip(
    BuildContext context,
    String label,
    String? projectId,
    String? current,
    ColorScheme cs,
  ) {
    final selected = current == projectId;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: selected,
        onSelected: (_) {
          ref.read(materialProjectFilterProvider.notifier).update(projectId);
        },
        selectedColor: cs.secondaryContainer,
        labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: selected
                  ? cs.onSecondaryContainer
                  : cs.onSurfaceVariant,
            ),
        side: BorderSide(
          color: selected
              ? cs.secondary.withValues(alpha: 0.5)
              : cs.outlineVariant,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.xxl)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  void _showSortModal(
      BuildContext context, MaterialSortOption current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(AppRadius.xxl)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Sort Materials',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              ..._sortOptions.map(
                (o) => ListTile(
                  title: Text(o.$1),
                  leading: Icon(o.$2,
                      color:
                          current == o.$3
                              ? Theme.of(context).colorScheme.primary
                              : null),
                  trailing: current == o.$3
                      ? Icon(Icons.check_rounded,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    ref.read(materialSortOptionProvider.notifier).update(o.$3);
                    Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  static const _sortOptions = [
    ('Name A → Z', Icons.sort_by_alpha_rounded, MaterialSortOption.nameAZ),
    ('Name Z → A', Icons.sort_by_alpha_rounded, MaterialSortOption.nameZA),
    ('Newest First', Icons.access_time_rounded, MaterialSortOption.newestFirst),
    ('Oldest First', Icons.history_rounded, MaterialSortOption.oldestFirst),
    ('Highest Stock', Icons.trending_up_rounded,
        MaterialSortOption.highestStock),
    ('Lowest Stock', Icons.trending_down_rounded,
        MaterialSortOption.lowestStock),
    ('Low Stock First', Icons.warning_amber_rounded,
        MaterialSortOption.lowStockFirst),
  ];
}
