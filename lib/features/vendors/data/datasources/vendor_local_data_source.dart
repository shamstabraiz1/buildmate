import '../../../../core/database/database_helper.dart';
import '../models/vendor_model.dart';

// ─── Abstract Interface ───────────────────────────────────────────────────────

abstract class VendorLocalDataSource {
  Future<void> insertVendor(VendorModel vendor);
  Future<void> updateVendor(VendorModel vendor);
  Future<void> deleteVendor(String id);
  Future<List<VendorModel>> getVendors();
  Future<VendorModel?> getVendorById(String id);
}

// ─── SQLite Implementation ────────────────────────────────────────────────────

class VendorLocalDataSourceImpl implements VendorLocalDataSource {
  VendorLocalDataSourceImpl(this.dbHelper);

  final DatabaseHelper dbHelper;
  static const String _table = 'vendors';

  @override
  Future<void> insertVendor(VendorModel vendor) async {
    final db = await dbHelper.database;
    await db.insert(_table, vendor.toMap());
  }

  @override
  Future<void> updateVendor(VendorModel vendor) async {
    final db = await dbHelper.database;
    await db.update(
      _table,
      vendor.toMap(),
      where: 'id = ?',
      whereArgs: [vendor.id],
    );
  }

  @override
  Future<void> deleteVendor(String id) async {
    final db = await dbHelper.database;
    await db.update(
      _table,
      {'isDeleted': 1, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<VendorModel>> getVendors() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      _table,
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'name ASC',
    );
    return maps.map(VendorModel.fromMap).toList();
  }

  @override
  Future<VendorModel?> getVendorById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      _table,
      where: 'id = ? AND isDeleted = ?',
      whereArgs: [id, 0],
      limit: 1,
    );
    return maps.isNotEmpty ? VendorModel.fromMap(maps.first) : null;
  }
}
