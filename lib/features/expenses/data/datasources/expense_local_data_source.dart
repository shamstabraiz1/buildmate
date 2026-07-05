import '../../../../core/database/database_helper.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<void> insertExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<List<ExpenseModel>> getExpenses();
  Future<ExpenseModel?> getExpenseById(String id);
  Future<List<ExpenseModel>> getExpensesByProjectId(String projectId);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  ExpenseLocalDataSourceImpl(this.dbHelper);

  final DatabaseHelper dbHelper;
  static const String tableName = 'expenses';

  @override
  Future<void> insertExpense(ExpenseModel expense) async {
    final db = await dbHelper.database;
    await db.insert(tableName, expense.toMap());
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    final db = await dbHelper.database;
    await db.update(
      tableName,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    final db = await dbHelper.database;
    // Soft delete implementation
    await db.update(
      tableName,
      {
        'isDeleted': 1,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'isDeleted = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => ExpenseModel.fromMap(maps[i]));
  }

  @override
  Future<ExpenseModel?> getExpenseById(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ? AND isDeleted = ?',
      whereArgs: [id, 0],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return ExpenseModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<ExpenseModel>> getExpensesByProjectId(String projectId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'projectId = ? AND isDeleted = ?',
      whereArgs: [projectId, 0],
    );
    return List.generate(maps.length, (i) => ExpenseModel.fromMap(maps[i]));
  }
}
