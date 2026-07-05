import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';
import 'expense_local_data_source.dart';

class ExpenseHiveDataSourceImpl implements ExpenseLocalDataSource {
  ExpenseHiveDataSourceImpl();

  static const String _boxName = 'expenses';

  Future<Box> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  @override
  Future<void> insertExpense(ExpenseModel expense) async {
    final box = await _box;
    await box.put(expense.id, expense.toMap());
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    final box = await _box;
    await box.put(expense.id, expense.toMap());
  }

  @override
  Future<void> deleteExpense(String id) async {
    final box = await _box;
    final map = box.get(id);
    if (map != null) {
      // Soft delete by updating the isDeleted flag
      final Map<String, dynamic> updatedMap = Map<String, dynamic>.from(map);
      updatedMap['isDeleted'] = 1;
      updatedMap['updatedAt'] = DateTime.now().toIso8601String();
      await box.put(id, updatedMap);
    }
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final box = await _box;
    final list = box.values.toList();
    
    // Only return expenses that are not soft-deleted
    return list
        .map((e) => ExpenseModel.fromMap(Map<String, dynamic>.from(e)))
        .where((e) => !e.isDeleted)
        .toList();
  }

  @override
  Future<ExpenseModel?> getExpenseById(String id) async {
    final box = await _box;
    final map = box.get(id);
    if (map != null) {
      final e = ExpenseModel.fromMap(Map<String, dynamic>.from(map));
      if (!e.isDeleted) {
        return e;
      }
    }
    return null;
  }

  @override
  Future<List<ExpenseModel>> getExpensesByProjectId(String projectId) async {
    final allExpenses = await getExpenses();
    return allExpenses.where((e) => e.projectId == projectId).toList();
  }
}
