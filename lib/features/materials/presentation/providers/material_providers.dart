import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_helper.dart';
import '../../data/datasources/material_hive_data_source.dart';
import '../../data/datasources/material_local_data_source.dart';
import '../../data/models/material_model.dart';
import '../../data/models/material_transaction_model.dart';
import '../../data/repositories/material_repository_impl.dart';
import '../../domain/repositories/material_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dependency Injection
// ─────────────────────────────────────────────────────────────────────────────

final materialDataSourceProvider = Provider<MaterialLocalDataSource>((ref) {
  if (kIsWeb) return MaterialHiveDataSourceImpl();
  return MaterialLocalDataSourceImpl(DatabaseHelper.instance);
});

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  final ds = ref.watch(materialDataSourceProvider);
  return MaterialRepositoryImpl(ds);
});

// ─────────────────────────────────────────────────────────────────────────────
// Materials Notifier (CRUD)
// ─────────────────────────────────────────────────────────────────────────────

class MaterialsNotifier extends AsyncNotifier<List<MaterialModel>> {
  @override
  FutureOr<List<MaterialModel>> build() => _load();

  Future<List<MaterialModel>> _load() =>
      ref.read(materialRepositoryProvider).getAllMaterials();

  Future<void> addMaterial(MaterialModel material) async {
    await ref.read(materialRepositoryProvider).addMaterial(material);
    ref.invalidateSelf();
  }

  Future<void> updateMaterial(MaterialModel material) async {
    await ref.read(materialRepositoryProvider).updateMaterial(material);
    ref.invalidateSelf();
  }

  Future<void> deleteMaterial(String id) async {
    await ref.read(materialRepositoryProvider).deleteMaterial(id);
    ref.invalidateSelf();
  }

  /// Convenience: Add a transaction and refresh parent list (stock sync handled in repo)
  Future<void> addTransaction(MaterialTransactionModel txn) async {
    await ref.read(materialRepositoryProvider).addTransaction(txn);
    ref.invalidateSelf();
    // Also invalidate the transactions family for this material
    ref.invalidate(materialTransactionsProvider(txn.materialId));
  }

  Future<void> updateTransaction(MaterialTransactionModel txn) async {
    await ref.read(materialRepositoryProvider).updateTransaction(txn);
    ref.invalidateSelf();
    ref.invalidate(materialTransactionsProvider(txn.materialId));
  }

  Future<void> deleteTransaction(String txnId, String materialId) async {
    await ref
        .read(materialRepositoryProvider)
        .deleteTransaction(txnId, materialId);
    ref.invalidateSelf();
    ref.invalidate(materialTransactionsProvider(materialId));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }
}

final materialsNotifierProvider =
    AsyncNotifierProvider<MaterialsNotifier, List<MaterialModel>>(
  MaterialsNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Transactions (per material) — family provider
// ─────────────────────────────────────────────────────────────────────────────

final materialTransactionsProvider =
    FutureProvider.family<List<MaterialTransactionModel>, String>(
  (ref, materialId) async {
    final repo = ref.watch(materialRepositoryProvider);
    return repo.getTransactionsForMaterial(materialId);
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Search / Filter / Sort State Providers
// ─────────────────────────────────────────────────────────────────────────────

class MaterialSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => state = value;
}
final materialSearchQueryProvider = NotifierProvider<MaterialSearchQueryNotifier, String>(MaterialSearchQueryNotifier.new);

class MaterialCategoryFilterNotifier extends Notifier<MaterialCategory?> {
  @override
  MaterialCategory? build() => null;
  void update(MaterialCategory? value) => state = value;
}
final materialCategoryFilterProvider = NotifierProvider<MaterialCategoryFilterNotifier, MaterialCategory?>(MaterialCategoryFilterNotifier.new);

class MaterialProjectFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? value) => state = value;
}
final materialProjectFilterProvider = NotifierProvider<MaterialProjectFilterNotifier, String?>(MaterialProjectFilterNotifier.new);

class MaterialSortOptionNotifier extends Notifier<MaterialSortOption> {
  @override
  MaterialSortOption build() => MaterialSortOption.nameAZ;
  void update(MaterialSortOption value) => state = value;
}
final materialSortOptionProvider = NotifierProvider<MaterialSortOptionNotifier, MaterialSortOption>(MaterialSortOptionNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Computed: Filtered + Sorted list (used directly by MaterialsScreen)
// ─────────────────────────────────────────────────────────────────────────────

final filteredMaterialsProvider = Provider<List<MaterialModel>>((ref) {
  final asyncMaterials = ref.watch(materialsNotifierProvider);
  final all = asyncMaterials.value ?? [];

  final query = ref.watch(materialSearchQueryProvider).toLowerCase();
  final categoryFilter = ref.watch(materialCategoryFilterProvider);
  final projectFilter = ref.watch(materialProjectFilterProvider);
  final sortOption = ref.watch(materialSortOptionProvider);

  var filtered = all.where((m) {
    // Search filter
    if (query.isNotEmpty) {
      final matches = m.name.toLowerCase().contains(query) ||
          m.materialNumber.toLowerCase().contains(query) ||
          m.displayCategory.toLowerCase().contains(query) ||
          (m.notes?.toLowerCase().contains(query) ?? false);
      if (!matches) return false;
    }
    // Category filter
    if (categoryFilter != null && m.category != categoryFilter) return false;
    // Project filter
    if (projectFilter != null && m.projectId != projectFilter) return false;
    return true;
  }).toList();

  // Sorting
  filtered.sort((a, b) {
    switch (sortOption) {
      case MaterialSortOption.nameAZ:
        return a.name.compareTo(b.name);
      case MaterialSortOption.nameZA:
        return b.name.compareTo(a.name);
      case MaterialSortOption.newestFirst:
        return b.createdAt.compareTo(a.createdAt);
      case MaterialSortOption.oldestFirst:
        return a.createdAt.compareTo(b.createdAt);
      case MaterialSortOption.highestStock:
        return b.quantityRemaining.compareTo(a.quantityRemaining);
      case MaterialSortOption.lowestStock:
        return a.quantityRemaining.compareTo(b.quantityRemaining);
      case MaterialSortOption.lowStockFirst:
        final aLow = a.isLowStock || a.isOutOfStock ? 0 : 1;
        final bLow = b.isLowStock || b.isOutOfStock ? 0 : 1;
        if (aLow != bLow) return aLow.compareTo(bLow);
        return a.name.compareTo(b.name);
    }
  });

  return filtered;
});

// ─────────────────────────────────────────────────────────────────────────────
// Project-scoped materials
// ─────────────────────────────────────────────────────────────────────────────

final materialsByProjectProvider =
    FutureProvider.family<List<MaterialModel>, String>((ref, projectId) async {
  // Prefer the cached list from the notifier when available
  final cached = ref.watch(materialsNotifierProvider).value;
  if (cached != null) {
    return cached.where((m) => m.projectId == projectId).toList();
  }
  return ref.read(materialRepositoryProvider).getMaterialsByProjectId(projectId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard-Ready Inventory Statistics
// ─────────────────────────────────────────────────────────────────────────────

/// Aggregated inventory statistics exposed for Dashboard consumption.
class MaterialInventoryStats {
  const MaterialInventoryStats({
    required this.totalMaterials,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalInventoryValue,
    required this.totalPurchasedValue,
    required this.totalUsedQuantityByCategory,
  });

  final int totalMaterials;
  final int lowStockCount;
  final int outOfStockCount;
  final double totalInventoryValue;   // sum(quantityRemaining * unitPrice)
  final double totalPurchasedValue;   // sum(quantityPurchased * unitPrice)
  final Map<MaterialCategory, double> totalUsedQuantityByCategory;

  static const empty = MaterialInventoryStats(
    totalMaterials: 0,
    lowStockCount: 0,
    outOfStockCount: 0,
    totalInventoryValue: 0,
    totalPurchasedValue: 0,
    totalUsedQuantityByCategory: {},
  );
}

final materialInventoryStatsProvider = Provider<MaterialInventoryStats>((ref) {
  final materials = ref.watch(materialsNotifierProvider).value ?? [];

  if (materials.isEmpty) return MaterialInventoryStats.empty;

  int lowStock = 0;
  int outOfStock = 0;
  double inventoryValue = 0;
  double purchasedValue = 0;
  final usedByCategory = <MaterialCategory, double>{};

  for (final m in materials) {
    if (m.isLowStock) lowStock++;
    if (m.isOutOfStock) outOfStock++;
    inventoryValue += m.quantityRemaining * m.unitPrice;
    purchasedValue += m.totalCost;
    usedByCategory.update(
      m.category,
      (v) => v + m.quantityUsed,
      ifAbsent: () => m.quantityUsed,
    );
  }

  return MaterialInventoryStats(
    totalMaterials: materials.length,
    lowStockCount: lowStock,
    outOfStockCount: outOfStock,
    totalInventoryValue: inventoryValue,
    totalPurchasedValue: purchasedValue,
    totalUsedQuantityByCategory: usedByCategory,
  );
});

/// Low-stock count only (for badge display on navigation)
final lowStockCountProvider = Provider<int>((ref) {
  return ref.watch(materialInventoryStatsProvider).lowStockCount;
});

/// Low stock materials list (convenience for alerts)
final lowStockMaterialsProvider = Provider<List<MaterialModel>>((ref) {
  final materials = ref.watch(materialsNotifierProvider).value ?? [];
  return materials
      .where((m) => m.isLowStock || m.isOutOfStock)
      .toList()
    ..sort((a, b) => a.quantityRemaining.compareTo(b.quantityRemaining));
});
