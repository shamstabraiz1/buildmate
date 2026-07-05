import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/inputs/app_search_bar.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../data/materials_dummy_data.dart';
import '../widgets/material_card.dart';
import 'add_material_screen.dart';
import 'material_details_screen.dart';
import 'suppliers_screen.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  MaterialCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MaterialModel> get _filteredMaterials {
    return MaterialsDummyData.materials.where((m) {
      final matchesSearch = m.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || m.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final materials = _filteredMaterials;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Material Inventory',
          subtitle: 'Manage stock and suppliers',
          showBackButton: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.local_shipping_outlined),
              tooltip: 'Suppliers',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SuppliersScreen()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Material(
              color: colorScheme.surface,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                child: Column(
                  children: [
                    AppSearchBar(
                      hintText: 'Search materials...',
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', null),
                          ...MaterialCategory.values.map((cat) {
                            return _buildFilterChip(MaterialsDummyData.categoryLabels[cat] ?? '', cat);
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: materials.isEmpty
                  ? EmptyStateWidget(
                      icon: const Icon(Icons.inventory_2_outlined),
                      title: 'No materials found',
                      message: 'Try adjusting your search or filters.',
                      actionLabel: _searchQuery.isNotEmpty || _selectedCategory != null ? 'Clear Filters' : null,
                      onActionPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _selectedCategory = null;
                        });
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl + AppSpacing.xxl),
                      itemCount: materials.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final material = materials[index];
                        return MaterialCard(
                          material: material,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MaterialDetailsScreen(materialId: material.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddMaterialScreen()),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Material'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.xxl)),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, MaterialCategory? category) {
    final isSelected = _selectedCategory == category;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategory = category),
        showCheckmark: isSelected,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? colorScheme.primary.withValues(alpha: 0.5) : colorScheme.outlineVariant,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.xxl)),
        ),
      ),
    );
  }
}
