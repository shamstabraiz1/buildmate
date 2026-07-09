import '../../domain/repositories/vendor_repository.dart';
import '../datasources/vendor_local_data_source.dart';
import '../models/vendor_model.dart';

class VendorRepositoryImpl implements VendorRepository {
  const VendorRepositoryImpl(this._dataSource);

  final VendorLocalDataSource _dataSource;

  @override
  Future<void> addVendor(VendorModel vendor) => _dataSource.insertVendor(vendor);

  @override
  Future<void> updateVendor(VendorModel vendor) => _dataSource.updateVendor(vendor);

  @override
  Future<void> deleteVendor(String id) => _dataSource.deleteVendor(id);

  @override
  Future<List<VendorModel>> getAllVendors() => _dataSource.getVendors();

  @override
  Future<VendorModel?> getVendorById(String id) => _dataSource.getVendorById(id);

  @override
  Future<List<VendorModel>> searchVendors(String query) async {
    final all = await _dataSource.getVendors();
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((v) {
      return v.name.toLowerCase().contains(q) ||
          (v.contactPerson?.toLowerCase().contains(q) ?? false) ||
          (v.phone?.toLowerCase().contains(q) ?? false) ||
          (v.email?.toLowerCase().contains(q) ?? false) ||
          (v.address?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}
