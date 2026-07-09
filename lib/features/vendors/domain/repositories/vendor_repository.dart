import '../../data/models/vendor_model.dart';

abstract class VendorRepository {
  Future<void> addVendor(VendorModel vendor);
  Future<void> updateVendor(VendorModel vendor);
  Future<void> deleteVendor(String id);
  Future<List<VendorModel>> getAllVendors();
  Future<VendorModel?> getVendorById(String id);
  Future<List<VendorModel>> searchVendors(String query);
}
