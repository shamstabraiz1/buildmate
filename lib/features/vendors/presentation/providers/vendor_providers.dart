import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_helper.dart';
import '../../data/datasources/vendor_hive_data_source.dart';
import '../../data/datasources/vendor_local_data_source.dart';
import '../../data/models/vendor_model.dart';
import '../../data/repositories/vendor_repository_impl.dart';
import '../../domain/repositories/vendor_repository.dart';

// ─── Dependency Injection ─────────────────────────────────────────────────────

final vendorDataSourceProvider = Provider<VendorLocalDataSource>((ref) {
  if (kIsWeb) return VendorHiveDataSourceImpl();
  return VendorLocalDataSourceImpl(DatabaseHelper.instance);
});

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  final ds = ref.watch(vendorDataSourceProvider);
  return VendorRepositoryImpl(ds);
});

// ─── State Notifier ───────────────────────────────────────────────────────────

class VendorsNotifier extends AsyncNotifier<List<VendorModel>> {
  @override
  FutureOr<List<VendorModel>> build() => _load();

  Future<List<VendorModel>> _load() =>
      ref.read(vendorRepositoryProvider).getAllVendors();

  Future<void> addVendor(VendorModel vendor) async {
    await ref.read(vendorRepositoryProvider).addVendor(vendor);
    ref.invalidateSelf();
  }

  Future<void> updateVendor(VendorModel vendor) async {
    await ref.read(vendorRepositoryProvider).updateVendor(vendor);
    ref.invalidateSelf();
  }

  Future<void> deleteVendor(String id) async {
    await ref.read(vendorRepositoryProvider).deleteVendor(id);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }
}

final vendorsNotifierProvider =
    AsyncNotifierProvider<VendorsNotifier, List<VendorModel>>(
  VendorsNotifier.new,
);

// ─── Convenience Provider: lookup by id ───────────────────────────────────────

final vendorByIdProvider =
    Provider.family<VendorModel?, String>((ref, id) {
  final vendors = ref.watch(vendorsNotifierProvider).value ?? [];
  return vendors.firstWhere(
    (v) => v.id == id,
    orElse: () => VendorModel(
      id: '',
      uuid: '',
      name: 'Unknown Vendor',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  );
});
