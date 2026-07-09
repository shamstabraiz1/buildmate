import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../../shared/widgets/layout/custom_scaffold.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../providers/expense_providers.dart';
import '../widgets/expense_card.dart';
import '../../data/models/expense_model.dart';
import '../../../dashboard/presentation/widgets/dashboard_bottom_nav.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  ExpenseSortOption _sortOption = ExpenseSortOption.newest;
  String? _selectedProjectId; // null means all projects

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    
    final expensesState = ref.watch(expensesNotifierProvider);
    final projectsState = ref.watch(projectsNotifierProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
      child: CustomScaffold(
        appBar: CustomAppBar(
          title: 'Expenses',
          subtitle: 'Track and manage your expenses',
          actions: [
            IconButton(
              icon: const Icon(Icons.sort_rounded),
              onPressed: () => _showSortModal(context),
              tooltip: 'Sort Expenses',
            ),
          ],
        ),
        bottomNavigationBar: const DashboardBottomNav(
          selectedDestination: DashboardNavDestination.expenses,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddExpenseScreen(),
              ),
            );
          },
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 4,
          child: const Icon(Icons.add_rounded),
        ),
        body: Column(
          children: [
            // Filter bar
            if (projectsState.hasValue && projectsState.value!.isNotEmpty)
              _buildFilterBar(projectsState.value!),
              
            Expanded(
              child: expensesState.when(
                data: (expenses) {
                  var filteredList = expenses;
                  if (_selectedProjectId != null) {
                    filteredList = filteredList
                        .where((e) => e.projectId == _selectedProjectId)
                        .toList();
                  }

                  // Sort
                  filteredList.sort((a, b) {
                    switch (_sortOption) {
                      case ExpenseSortOption.newest:
                        return b.date.compareTo(a.date);
                      case ExpenseSortOption.oldest:
                        return a.date.compareTo(b.date);
                      case ExpenseSortOption.highestAmount:
                        return b.amount.compareTo(a.amount);
                      case ExpenseSortOption.lowestAmount:
                        return a.amount.compareTo(b.amount);
                    }
                  });

                  if (filteredList.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icon(Icons.receipt_long_rounded, size: 64),
                      title: 'No expenses found',
                      message: 'You have not added any expenses matching the criteria.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      top: AppSpacing.md,
                      bottom: AppSpacing.xxxl * 2, // Space for FAB
                    ),
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final expense = filteredList[index];
                      // Find project name
                      final projName = projectsState.hasValue 
                          ? projectsState.value!
                              .where((p) => p.id == expense.projectId)
                              .firstOrNull?.name ?? 'Unknown Project'
                          : 'Unknown Project';

                      return ExpenseCard(
                        expense: expense,
                        projectName: projName,
                        onTap: () {
                          // Tap to view/edit expense
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddExpenseScreen(expense: expense),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: AppLoadingIndicator()),
                error: (err, stack) => Center(
                  child: Text(
                    'Failed to load expenses.\n$err',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(List<dynamic> projects) { // Using dynamic or ProjectModel
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All Projects', null, colorScheme),
          const SizedBox(width: AppSpacing.sm),
          ...projects.map((p) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _buildFilterChip(p.name, p.id, colorScheme),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? projectId, ColorScheme colorScheme) {
    final isSelected = _selectedProjectId == projectId;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedProjectId = selected ? projectId : null;
        });
      },
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  void _showSortModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Sort Expenses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildSortTile('Newest First', ExpenseSortOption.newest, ctx),
              _buildSortTile('Oldest First', ExpenseSortOption.oldest, ctx),
              _buildSortTile('Highest Amount', ExpenseSortOption.highestAmount, ctx),
              _buildSortTile('Lowest Amount', ExpenseSortOption.lowestAmount, ctx),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortTile(String title, ExpenseSortOption option, BuildContext ctx) {
    return ListTile(
      title: Text(title),
      trailing: _sortOption == option ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        setState(() {
          _sortOption = option;
        });
        Navigator.pop(ctx);
      },
    );
  }
}
