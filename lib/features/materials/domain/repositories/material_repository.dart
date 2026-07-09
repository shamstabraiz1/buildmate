import '../../data/models/material_model.dart';
import '../../data/models/material_transaction_model.dart';

abstract class MaterialRepository {
  // Materials
  Future<void> addMaterial(MaterialModel material);
  Future<void> updateMaterial(MaterialModel material);
  Future<void> deleteMaterial(String id);
  Future<List<MaterialModel>> getAllMaterials();
  Future<MaterialModel?> getMaterialById(String id);
  Future<List<MaterialModel>> getMaterialsByProjectId(String projectId);
  Future<List<MaterialModel>> searchMaterials(String query);
  Future<List<MaterialModel>> getLowStockMaterials();

  // Transactions
  Future<void> addTransaction(MaterialTransactionModel transaction);
  Future<void> updateTransaction(MaterialTransactionModel transaction);
  Future<void> deleteTransaction(String id, String materialId);
  Future<List<MaterialTransactionModel>> getTransactionsForMaterial(
    String materialId,
  );
  Future<List<MaterialTransactionModel>> getTransactionsForProject(
    String projectId,
  );
}
