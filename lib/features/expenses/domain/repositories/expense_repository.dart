import '../../data/models/expense_model.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<List<ExpenseModel>> getAllExpenses();
  Future<ExpenseModel?> getExpenseById(String id);
  Future<List<ExpenseModel>> getExpensesByProjectId(String projectId);
  Future<List<ExpenseModel>> searchExpenses(String query);
}
