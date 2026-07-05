enum MaterialCategory { cement, steel, bricks, electrical, plumbing, paint, sand }
enum TransactionType { incoming, outgoing }

class MaterialModel {
  const MaterialModel({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.quantity,
    required this.reorderLevel,
    required this.supplierId,
    required this.averageUnitPrice,
  });

  final String id;
  final String name;
  final MaterialCategory category;
  final String unit;
  final double quantity;
  final double reorderLevel;
  final String supplierId;
  final double averageUnitPrice;

  bool get isLowStock => quantity <= reorderLevel;
}

class SupplierModel {
  const SupplierModel({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.phone,
    required this.rating,
  });

  final String id;
  final String companyName;
  final String contactPerson;
  final String phone;
  final double rating;
}

class MaterialTransaction {
  const MaterialTransaction({
    required this.id,
    required this.materialId,
    required this.date,
    required this.type,
    required this.quantity,
    this.notes,
  });

  final String id;
  final String materialId;
  final DateTime date;
  final TransactionType type;
  final double quantity;
  final String? notes;
}

class MaterialsDummyData {
  const MaterialsDummyData._();

  static const categoryLabels = {
    MaterialCategory.cement: 'Cement',
    MaterialCategory.steel: 'Steel',
    MaterialCategory.bricks: 'Bricks & Blocks',
    MaterialCategory.electrical: 'Electrical',
    MaterialCategory.plumbing: 'Plumbing',
    MaterialCategory.paint: 'Paint & Finishes',
    MaterialCategory.sand: 'Sand & Aggregates',
  };

  static final List<SupplierModel> suppliers = [
    const SupplierModel(
      id: 'sup1',
      companyName: 'UltraTech Distributors',
      contactPerson: 'Vikram Singh',
      phone: '9876543210',
      rating: 4.8,
    ),
    const SupplierModel(
      id: 'sup2',
      companyName: 'Tata Steel Traders',
      contactPerson: 'Rajeev Sharma',
      phone: '9876543211',
      rating: 4.9,
    ),
    const SupplierModel(
      id: 'sup3',
      companyName: 'Metro Building Materials',
      contactPerson: 'Anil Desai',
      phone: '9876543212',
      rating: 4.2,
    ),
    const SupplierModel(
      id: 'sup4',
      companyName: 'Finolex Regional Hub',
      contactPerson: 'Sneha Patel',
      phone: '9876543213',
      rating: 4.6,
    ),
  ];

  static final List<MaterialModel> materials = [
    const MaterialModel(
      id: 'm1',
      name: 'OPC 53 Grade Cement',
      category: MaterialCategory.cement,
      unit: 'Bags',
      quantity: 150,
      reorderLevel: 200,
      supplierId: 'sup1',
      averageUnitPrice: 380,
    ),
    const MaterialModel(
      id: 'm2',
      name: 'TMT Bars 12mm',
      category: MaterialCategory.steel,
      unit: 'Tons',
      quantity: 12.5,
      reorderLevel: 5.0,
      supplierId: 'sup2',
      averageUnitPrice: 55000,
    ),
    const MaterialModel(
      id: 'm3',
      name: 'Red Clay Bricks',
      category: MaterialCategory.bricks,
      unit: 'Pieces',
      quantity: 12000,
      reorderLevel: 5000,
      supplierId: 'sup3',
      averageUnitPrice: 8,
    ),
    const MaterialModel(
      id: 'm4',
      name: 'PVC Pipes 1 Inch',
      category: MaterialCategory.plumbing,
      unit: 'Meters',
      quantity: 45,
      reorderLevel: 50,
      supplierId: 'sup4',
      averageUnitPrice: 120,
    ),
    const MaterialModel(
      id: 'm5',
      name: 'River Sand',
      category: MaterialCategory.sand,
      unit: 'Brass',
      quantity: 8,
      reorderLevel: 10,
      supplierId: 'sup3',
      averageUnitPrice: 4500,
    ),
    const MaterialModel(
      id: 'm6',
      name: 'Copper Wire 2.5 sq mm',
      category: MaterialCategory.electrical,
      unit: 'Coils',
      quantity: 25,
      reorderLevel: 10,
      supplierId: 'sup4',
      averageUnitPrice: 1800,
    ),
  ];

  static final List<MaterialTransaction> transactions = [
    MaterialTransaction(
      id: 't1',
      materialId: 'm1',
      date: DateTime(2026, 7, 2, 10, 30),
      type: TransactionType.incoming,
      quantity: 500,
      notes: 'Delivery from UltraTech',
    ),
    MaterialTransaction(
      id: 't2',
      materialId: 'm1',
      date: DateTime(2026, 7, 3, 14, 0),
      type: TransactionType.outgoing,
      quantity: 350,
      notes: 'Used in Foundation Phase 2',
    ),
    MaterialTransaction(
      id: 't3',
      materialId: 'm2',
      date: DateTime(2026, 7, 1, 9, 15),
      type: TransactionType.outgoing,
      quantity: 2.5,
      notes: 'Column reinforcement Tower A',
    ),
    MaterialTransaction(
      id: 't4',
      materialId: 'm4',
      date: DateTime(2026, 7, 4, 11, 0),
      type: TransactionType.outgoing,
      quantity: 10,
      notes: 'Bathroom fittings ground floor',
    ),
    MaterialTransaction(
      id: 't5',
      materialId: 'm5',
      date: DateTime(2026, 6, 28, 16, 45),
      type: TransactionType.incoming,
      quantity: 12,
      notes: 'Sand delivery',
    ),
    MaterialTransaction(
      id: 't6',
      materialId: 'm5',
      date: DateTime(2026, 7, 2, 8, 30),
      type: TransactionType.outgoing,
      quantity: 4,
      notes: 'Plastering work',
    ),
  ];
}
