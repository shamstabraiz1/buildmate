import 'package:uuid/uuid.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum TransactionType {
  purchased,
  used,
  returned,
  adjustment,
  damaged,
}

// ─── MaterialTransactionModel ─────────────────────────────────────────────────

class MaterialTransactionModel {
  const MaterialTransactionModel({
    required this.id,
    required this.uuid,
    required this.materialId,
    required this.projectId,
    this.vendorId,
    required this.type,
    required this.quantity,
    this.unitPrice,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final String id;
  final String uuid;
  final String materialId;
  final String projectId;
  final String? vendorId;   // FK → vendors.id (used for purchased / returned)
  final TransactionType type;
  final double quantity;
  final double? unitPrice;  // snapshot price at time of purchase
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  // ─── Computed ─────────────────────────────────────────────────────────────

  /// Signed delta applied to quantityPurchased (+) or quantityUsed (+)
  bool get increasesStock =>
      type == TransactionType.purchased || type == TransactionType.returned;

  bool get decreasesStock =>
      type == TransactionType.used ||
      type == TransactionType.damaged;

  double? get lineTotal =>
      unitPrice != null ? quantity * unitPrice! : null;

  static const typeLabels = <TransactionType, String>{
    TransactionType.purchased: 'Purchased',
    TransactionType.used: 'Used',
    TransactionType.returned: 'Returned',
    TransactionType.adjustment: 'Adjustment',
    TransactionType.damaged: 'Damaged',
  };

  // ─── Factory ──────────────────────────────────────────────────────────────

  factory MaterialTransactionModel.create({
    required String materialId,
    required String projectId,
    String? vendorId,
    required TransactionType type,
    required double quantity,
    double? unitPrice,
    required DateTime date,
    String? notes,
  }) {
    final now = DateTime.now();
    final uid = const Uuid().v4();
    return MaterialTransactionModel(
      id: uid,
      uuid: uid,
      materialId: materialId,
      projectId: projectId,
      vendorId: vendorId,
      type: type,
      quantity: quantity,
      unitPrice: unitPrice,
      date: date,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  MaterialTransactionModel copyWith({
    String? vendorId,
    TransactionType? type,
    double? quantity,
    double? unitPrice,
    DateTime? date,
    String? notes,
    bool? isDeleted,
    bool clearVendorId = false,
    bool clearUnitPrice = false,
    bool clearNotes = false,
  }) {
    return MaterialTransactionModel(
      id: id,
      uuid: uuid,
      materialId: materialId,
      projectId: projectId,
      vendorId: clearVendorId ? null : (vendorId ?? this.vendorId),
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unitPrice: clearUnitPrice ? null : (unitPrice ?? this.unitPrice),
      date: date ?? this.date,
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  // ─── Serialization ────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'materialId': materialId,
      'projectId': projectId,
      'vendorId': vendorId,
      'type': type.name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory MaterialTransactionModel.fromMap(Map<String, dynamic> map) {
    return MaterialTransactionModel(
      id: map['id'] as String,
      uuid: map['uuid'] as String? ?? map['id'] as String,
      materialId: map['materialId'] as String,
      projectId: map['projectId'] as String? ?? '',
      vendorId: map['vendorId'] as String?,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.purchased,
      ),
      quantity: (map['quantity'] as num).toDouble(),
      unitPrice:
          map['unitPrice'] != null ? (map['unitPrice'] as num).toDouble() : null,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isDeleted: (map['isDeleted'] as int? ?? 0) == 1,
    );
  }
}
