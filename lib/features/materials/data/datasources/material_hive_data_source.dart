import 'package:hive_flutter/hive_flutter.dart';
import '../models/material_model.dart';
import '../models/material_transaction_model.dart';
import 'material_local_data_source.dart';

class MaterialHiveDataSourceImpl implements MaterialLocalDataSource {
  static const _matBox = 'materials';
  static const _txnBox = 'material_transactions';

  Future<Box> get _materials async {
    if (!Hive.isBoxOpen(_matBox)) return Hive.openBox(_matBox);
    return Hive.box(_matBox);
  }

  Future<Box> get _transactions async {
    if (!Hive.isBoxOpen(_txnBox)) return Hive.openBox(_txnBox);
    return Hive.box(_txnBox);
  }

  // ── Materials ──────────────────────────────────────────────────────────────

  @override
  Future<void> insertMaterial(MaterialModel material) async {
    final box = await _materials;
    await box.put(material.id, material.toMap());
  }

  @override
  Future<void> updateMaterial(MaterialModel material) async {
    final box = await _materials;
    await box.put(material.id, material.toMap());
  }

  @override
  Future<void> deleteMaterial(String id) async {
    final box = await _materials;
    final raw = box.get(id);
    if (raw != null) {
      final updated = Map<String, dynamic>.from(raw as Map);
      updated['isDeleted'] = 1;
      updated['updatedAt'] = DateTime.now().toIso8601String();
      await box.put(id, updated);
    }
  }

  @override
  Future<List<MaterialModel>> getMaterials() async {
    final box = await _materials;
    return box.values
        .map(
          (e) => MaterialModel.fromMap(Map<String, dynamic>.from(e as Map)),
        )
        .where((m) => !m.isDeleted)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<MaterialModel?> getMaterialById(String id) async {
    final box = await _materials;
    final raw = box.get(id);
    if (raw == null) return null;
    final m = MaterialModel.fromMap(Map<String, dynamic>.from(raw as Map));
    return m.isDeleted ? null : m;
  }

  @override
  Future<List<MaterialModel>> getMaterialsByProjectId(
    String projectId,
  ) async {
    final all = await getMaterials();
    return all.where((m) => m.projectId == projectId).toList();
  }

  // ── Transactions ───────────────────────────────────────────────────────────

  @override
  Future<void> insertTransaction(MaterialTransactionModel txn) async {
    final box = await _transactions;
    await box.put(txn.id, txn.toMap());
  }

  @override
  Future<void> updateTransaction(MaterialTransactionModel txn) async {
    final box = await _transactions;
    await box.put(txn.id, txn.toMap());
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final box = await _transactions;
    final raw = box.get(id);
    if (raw != null) {
      final updated = Map<String, dynamic>.from(raw as Map);
      updated['isDeleted'] = 1;
      updated['updatedAt'] = DateTime.now().toIso8601String();
      await box.put(id, updated);
    }
  }

  @override
  Future<List<MaterialTransactionModel>> getTransactionsByMaterialId(
    String materialId,
  ) async {
    final box = await _transactions;
    return box.values
        .map(
          (e) => MaterialTransactionModel.fromMap(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .where((t) => !t.isDeleted && t.materialId == materialId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<MaterialTransactionModel>> getTransactionsByProjectId(
    String projectId,
  ) async {
    final box = await _transactions;
    return box.values
        .map(
          (e) => MaterialTransactionModel.fromMap(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .where((t) => !t.isDeleted && t.projectId == projectId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
