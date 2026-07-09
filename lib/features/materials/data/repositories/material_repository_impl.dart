import '../../domain/repositories/material_repository.dart';
import '../datasources/material_local_data_source.dart';
import '../models/material_model.dart';
import '../models/material_transaction_model.dart';

class MaterialRepositoryImpl implements MaterialRepository {
  const MaterialRepositoryImpl(this._dataSource);

  final MaterialLocalDataSource _dataSource;

  // ── Materials ──────────────────────────────────────────────────────────────

  @override
  Future<void> addMaterial(MaterialModel material) =>
      _dataSource.insertMaterial(material);

  @override
  Future<void> updateMaterial(MaterialModel material) =>
      _dataSource.updateMaterial(material);

  @override
  Future<void> deleteMaterial(String id) => _dataSource.deleteMaterial(id);

  @override
  Future<List<MaterialModel>> getAllMaterials() => _dataSource.getMaterials();

  @override
  Future<MaterialModel?> getMaterialById(String id) =>
      _dataSource.getMaterialById(id);

  @override
  Future<List<MaterialModel>> getMaterialsByProjectId(String projectId) =>
      _dataSource.getMaterialsByProjectId(projectId);

  @override
  Future<List<MaterialModel>> searchMaterials(String query) async {
    final all = await _dataSource.getMaterials();
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((m) {
      return m.name.toLowerCase().contains(q) ||
          m.materialNumber.toLowerCase().contains(q) ||
          m.displayCategory.toLowerCase().contains(q) ||
          (m.notes?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Future<List<MaterialModel>> getLowStockMaterials() async {
    final all = await _dataSource.getMaterials();
    return all
        .where((m) =>
            m.status == MaterialStatus.lowStock ||
            m.status == MaterialStatus.outOfStock)
        .toList();
  }

  // ── Transactions (with stock sync) ────────────────────────────────────────

  @override
  Future<void> addTransaction(MaterialTransactionModel transaction) async {
    // 1. Persist the transaction
    await _dataSource.insertTransaction(transaction);

    // 2. Update parent material quantities
    final material = await _dataSource.getMaterialById(transaction.materialId);
    if (material == null) return;

    final updated = _applyTransactionDelta(material, transaction, add: true);
    await _dataSource.updateMaterial(updated);
  }

  @override
  Future<void> updateTransaction(
    MaterialTransactionModel transaction,
  ) async {
    // Fetch old version to reverse its delta, then apply new one
    final allTxns = await _dataSource
        .getTransactionsByMaterialId(transaction.materialId);
    final old = allTxns.firstWhere(
      (t) => t.id == transaction.id,
      orElse: () => transaction,
    );

    await _dataSource.updateTransaction(transaction);

    final material = await _dataSource.getMaterialById(transaction.materialId);
    if (material == null) return;

    // Reverse old delta then apply new delta
    var updated = _applyTransactionDelta(material, old, add: false);
    updated = _applyTransactionDelta(updated, transaction, add: true);
    await _dataSource.updateMaterial(updated);
  }

  @override
  Future<void> deleteTransaction(String id, String materialId) async {
    // Fetch before soft-deleting so we can reverse the delta
    final txns = await _dataSource.getTransactionsByMaterialId(materialId);
    final txn = txns.where((t) => t.id == id).firstOrNull;

    await _dataSource.deleteTransaction(id);

    if (txn == null) return;
    final material = await _dataSource.getMaterialById(materialId);
    if (material == null) return;

    final updated = _applyTransactionDelta(material, txn, add: false);
    await _dataSource.updateMaterial(updated);
  }

  @override
  Future<List<MaterialTransactionModel>> getTransactionsForMaterial(
    String materialId,
  ) =>
      _dataSource.getTransactionsByMaterialId(materialId);

  @override
  Future<List<MaterialTransactionModel>> getTransactionsForProject(
    String projectId,
  ) =>
      _dataSource.getTransactionsByProjectId(projectId);

  // ── Private: delta calculation ─────────────────────────────────────────────

  /// [add] = true → apply the transaction's effect
  /// [add] = false → reverse the transaction's effect
  MaterialModel _applyTransactionDelta(
    MaterialModel material,
    MaterialTransactionModel txn,
    {required bool add}
  ) {
    final sign = add ? 1.0 : -1.0;
    double newPurchased = material.quantityPurchased;
    double newUsed = material.quantityUsed;

    switch (txn.type) {
      case TransactionType.purchased:
        newPurchased += sign * txn.quantity;
      case TransactionType.returned:
        // Returned to supplier reduces purchased total
        newPurchased -= sign * txn.quantity;
      case TransactionType.used:
      case TransactionType.damaged:
        newUsed += sign * txn.quantity;
      case TransactionType.adjustment:
        // Positive adjustment increases purchased; negative reduces used
        if (txn.quantity >= 0) {
          newPurchased += sign * txn.quantity;
        } else {
          newUsed += sign * txn.quantity.abs();
        }
    }

    // Clamp to zero to avoid negative values
    newPurchased = newPurchased.clamp(0, double.infinity);
    newUsed = newUsed.clamp(0, double.infinity);

    final newStatus = MaterialModel.computeStatus(
      newPurchased - newUsed,
      material.reorderLevel,
      material.status,
    );

    return material.copyWith(
      quantityPurchased: newPurchased,
      quantityUsed: newUsed,
      status: newStatus,
    );
  }
}
