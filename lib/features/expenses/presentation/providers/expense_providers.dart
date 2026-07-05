import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_helper.dart';
import '../../data/datasources/expense_local_data_source.dart';
import '../../data/datasources/expense_hive_data_source.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/repositories/expense_repository.dart';

// ─── Dependency Injection Providers ──────────────────────────────────────────

final expenseDatabaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final expenseDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  if (kIsWeb) {
    return ExpenseHiveDataSourceImpl();
  }
  final dbHelper = ref.watch(expenseDatabaseHelperProvider);
  return ExpenseLocalDataSourceImpl(dbHelper);
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final dataSource = ref.watch(expenseDataSourceProvider);
  return ExpenseRepositoryImpl(dataSource);
});

// ─── State Management (AsyncNotifier) ────────────────────────────────────────

class ExpensesNotifier extends AsyncNotifier<List<ExpenseModel>> {
  @override
  FutureOr<List<ExpenseModel>> build() async {
    return _loadExpenses();
  }

  Future<List<ExpenseModel>> _loadExpenses() async {
    final repo = ref.read(expenseRepositoryProvider);
    return await repo.getAllExpenses();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadExpenses());
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.addExpense(expense);
    await refresh();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.updateExpense(expense);
    await refresh();
  }

  Future<void> deleteExpense(String id) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.deleteExpense(id);
    await refresh();
  }
}

final expensesNotifierProvider =
    AsyncNotifierProvider<ExpensesNotifier, List<ExpenseModel>>(() {
  return ExpensesNotifier();
});

// ─── Project-Specific Expenses ───────────────────────────────────────────────

final expensesByProjectProvider =
    FutureProvider.family<List<ExpenseModel>, String>((ref, projectId) async {
  // Try to use the cached list if available
  final listState = ref.watch(expensesNotifierProvider);
  if (listState.hasValue) {
    return listState.value!.where((e) => e.projectId == projectId).toList();
  }
  
  // Otherwise fetch from db directly
  final repo = ref.read(expenseRepositoryProvider);
  return await repo.getExpensesByProjectId(projectId);
});
