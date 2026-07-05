import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  const ExpenseRepositoryImpl(this.localDataSource);

  final ExpenseLocalDataSource localDataSource;

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await localDataSource.insertExpense(expense);
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await localDataSource.updateExpense(expense);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await localDataSource.deleteExpense(id);
  }

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    return await localDataSource.getExpenses();
  }

  @override
  Future<ExpenseModel?> getExpenseById(String id) async {
    return await localDataSource.getExpenseById(id);
  }

  @override
  Future<List<ExpenseModel>> getExpensesByProjectId(String projectId) async {
    return await localDataSource.getExpensesByProjectId(projectId);
  }

  @override
  Future<List<ExpenseModel>> searchExpenses(String query) async {
    final all = await localDataSource.getExpenses();
    final lowerQ = query.toLowerCase();
    return all.where((e) {
      return e.expenseNumber.toLowerCase().contains(lowerQ) ||
          e.categoryId.toLowerCase().contains(lowerQ) ||
          (e.vendor?.toLowerCase().contains(lowerQ) ?? false) ||
          (e.notes?.toLowerCase().contains(lowerQ) ?? false);
    }).toList();
  }
}
