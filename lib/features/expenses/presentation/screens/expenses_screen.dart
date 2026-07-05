import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/inputs/app_search_bar.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../data/expenses_dummy_data.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';
import 'expense_details_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ExpenseCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExpenseModel> get _filteredExpenses {
    final filtered = ExpensesDummyData.expenses.where((e) {
      final matchesSearch = e.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || e.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final expenses = _filteredExpenses;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Expenses',
          subtitle: 'Track all project costs',
          showBackButton: false,
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
                      hintText: 'Search expenses...',
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
                          ...ExpenseCategory.values.map((cat) {
                            return _buildFilterChip(ExpensesDummyData.categoryLabels[cat] ?? '', cat);
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: expenses.isEmpty
                  ? EmptyStateWidget(
                      icon: const Icon(Icons.receipt_long_outlined),
                      title: 'No expenses found',
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
                      itemCount: expenses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return ExpenseCard(
                          expense: expense,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ExpenseDetailsScreen(expenseId: expense.id),
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
              MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Expense'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.xxl)),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, ExpenseCategory? category) {
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
