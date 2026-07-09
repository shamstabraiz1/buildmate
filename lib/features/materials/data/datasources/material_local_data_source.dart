import '../../../../core/database/database_helper.dart';
import '../models/material_model.dart';
import '../models/material_transaction_model.dart';

// ─── Abstract Interface ───────────────────────────────────────────────────────

abstract class MaterialLocalDataSource {
  // Materials CRUD
  Future<void> insertMaterial(MaterialModel material);
  Future<void> updateMaterial(MaterialModel material);
  Future<void> deleteMaterial(String id);
  Future<List<MaterialModel>> getMaterials();
  Future<MaterialModel?> getMaterialById(String id);
  Future<List<MaterialModel>> getMaterialsByProjectId(String projectId);

  // Transactions CRUD
  Future<void> insertTransaction(MaterialTransactionModel transaction);
  Future<void> updateTransaction(MaterialTransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<List<MaterialTransactionModel>> getTransactionsByMaterialId(
    String materialId,
  );
  Future<List<MaterialTransactionModel>> getTransactionsByProjectId(
    String projectId,
  );
}

// ─── SQLite Implementation ────────────────────────────────────────────────────

class MaterialLocalDataSourceImpl implements MaterialLocalDataSource {
  MaterialLocalDataSourceImpl(this._dbHelper);

  final DatabaseHelper _dbHelper;
  static const _matTable = 'materials';
  static const _txnTable = 'material_transactions';

  // ── Materials ──────────────────────────────────────────────────────────────

  @override
  Future<void> insertMaterial(MaterialModel material) async {
    final db = await _dbHelper.database;
    await db.insert(_matTable, material.toMap());
  }

  @override
  Future<void> updateMaterial(MaterialModel material) async {
    final db = await _dbHelper.database;
    await db.update(
      _matTable,
      material.toMap(),
      where: 'id = ?',
      whereArgs: [material.id],
    );
  }

  @override
  Future<void> deleteMaterial(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      _matTable,
      {'isDeleted': 1, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<MaterialModel>> getMaterials() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      _matTable,
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
    return maps.map(MaterialModel.fromMap).toList();
  }

  @override
  Future<MaterialModel?> getMaterialById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      _matTable,
      where: 'id = ? AND isDeleted = ?',
      whereArgs: [id, 0],
      limit: 1,
    );
    return maps.isNotEmpty ? MaterialModel.fromMap(maps.first) : null;
  }

  @override
  Future<List<MaterialModel>> getMaterialsByProjectId(
    String projectId,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      _matTable,
      where: 'projectId = ? AND isDeleted = ?',
      whereArgs: [projectId, 0],
      orderBy: 'createdAt DESC',
    );
    return maps.map(MaterialModel.fromMap).toList();
  }

  // ── Transactions ───────────────────────────────────────────────────────────

  @override
  Future<void> insertTransaction(MaterialTransactionModel txn) async {
    final db = await _dbHelper.database;
    await db.insert(_txnTable, txn.toMap());
  }

  @override
  Future<void> updateTransaction(MaterialTransactionModel txn) async {
    final db = await _dbHelper.database;
    await db.update(
      _txnTable,
      txn.toMap(),
      where: 'id = ?',
      whereArgs: [txn.id],
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      _txnTable,
      {'isDeleted': 1, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<MaterialTransactionModel>> getTransactionsByMaterialId(
    String materialId,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      _txnTable,
      where: 'materialId = ? AND isDeleted = ?',
      whereArgs: [materialId, 0],
      orderBy: 'date DESC',
    );
    return maps.map(MaterialTransactionModel.fromMap).toList();
  }

  @override
  Future<List<MaterialTransactionModel>> getTransactionsByProjectId(
    String projectId,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      _txnTable,
      where: 'projectId = ? AND isDeleted = ?',
      whereArgs: [projectId, 0],
      orderBy: 'date DESC',
    );
    return maps.map(MaterialTransactionModel.fromMap).toList();
  }
}
