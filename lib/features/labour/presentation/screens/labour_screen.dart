import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/inputs/app_search_bar.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../data/labour_dummy_data.dart';
import '../widgets/labour_card.dart';
import 'add_labour_screen.dart';
import 'labour_details_screen.dart';

/// Screen displaying the list of all labour workers.
class LabourScreen extends StatefulWidget {
  const LabourScreen({super.key});

  @override
  State<LabourScreen> createState() => _LabourScreenState();
}

class _LabourScreenState extends State<LabourScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  LabourRole? _selectedRole;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LabourModel> get _filteredWorkers {
    return LabourDummyData.workers.where((w) {
      final matchesSearch = w.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.phone.contains(_searchQuery) ||
          (LabourDummyData.roleLabels[w.role]?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesRole = _selectedRole == null || w.role == _selectedRole;
      return matchesSearch && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final workers = _filteredWorkers;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Labour Directory',
          subtitle: 'Manage workers and attendance',
          showBackButton: false,
        ),
        body: Column(
          children: [
            // Search and Filter Bar
            Material(
              color: colorScheme.surface,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                child: Column(
                  children: [
                    AppSearchBar(
                      hintText: 'Search by name, phone or role...',
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
                          ...LabourRole.values.map((role) {
                            return _buildFilterChip(LabourDummyData.roleLabels[role] ?? '', role);
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // List View
            Expanded(
              child: workers.isEmpty
                  ? EmptyStateWidget(
                      icon: const Icon(Icons.people_alt_outlined),
                      title: 'No workers found',
                      message: 'Try adjusting your search or filters.',
                      actionLabel: _searchQuery.isNotEmpty || _selectedRole != null ? 'Clear Filters' : null,
                      onActionPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _selectedRole = null;
                        });
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl + AppSpacing.xxl),
                      itemCount: workers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final worker = workers[index];
                        return LabourCard(
                          labour: worker,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LabourDetailsScreen(labourId: worker.id),
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
              MaterialPageRoute(builder: (_) => const AddLabourScreen()),
            );
          },
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Add Worker'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.xxl)),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, LabourRole? role) {
    final isSelected = _selectedRole == role;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedRole = role),
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
