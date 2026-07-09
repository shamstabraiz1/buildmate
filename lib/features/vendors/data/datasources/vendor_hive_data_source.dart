import 'package:hive_flutter/hive_flutter.dart';
import '../models/vendor_model.dart';
import 'vendor_local_data_source.dart';

class VendorHiveDataSourceImpl implements VendorLocalDataSource {
  static const String _boxName = 'vendors';

  Future<Box> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  @override
  Future<void> insertVendor(VendorModel vendor) async {
    final box = await _box;
    await box.put(vendor.id, vendor.toMap());
  }

  @override
  Future<void> updateVendor(VendorModel vendor) async {
    final box = await _box;
    await box.put(vendor.id, vendor.toMap());
  }

  @override
  Future<void> deleteVendor(String id) async {
    final box = await _box;
    final raw = box.get(id);
    if (raw != null) {
      final updated = Map<String, dynamic>.from(raw as Map);
      updated['isDeleted'] = 1;
      updated['updatedAt'] = DateTime.now().toIso8601String();
      await box.put(id, updated);
    }
  }

  @override
  Future<List<VendorModel>> getVendors() async {
    final box = await _box;
    return box.values
        .map((e) => VendorModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((v) => !v.isDeleted)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<VendorModel?> getVendorById(String id) async {
    final box = await _box;
    final raw = box.get(id);
    if (raw == null) return null;
    final v = VendorModel.fromMap(Map<String, dynamic>.from(raw as Map));
    return v.isDeleted ? null : v;
  }
}
