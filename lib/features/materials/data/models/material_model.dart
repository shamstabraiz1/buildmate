import 'package:flutter/material.dart' show IconData, Icons;
import 'package:uuid/uuid.dart';

import '../../../../core/utils/app_formatters.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum MaterialCategory {
  cement,
  steel,
  bricks,
  sand,
  gravel,
  timber,
  paint,
  electrical,
  plumbing,
  glass,
  tiles,
  hardware,
  fuel,
  other,
  custom,
}

enum MaterialStatus {
  available,
  lowStock,
  outOfStock,
  reserved,
  discontinued,
}

enum MaterialSortOption {
  nameAZ,
  nameZA,
  newestFirst,
  oldestFirst,
  highestStock,
  lowestStock,
  lowStockFirst,
}

// ─── MaterialModel ────────────────────────────────────────────────────────────

class MaterialModel {
  const MaterialModel({
    required this.id,
    required this.uuid,
    required this.materialNumber,
    required this.name,
    required this.category,
    this.customCategory,
    this.projectId,
    this.vendorId,
    required this.unit,
    required this.unitPrice,
    this.quantityPurchased = 0,
    this.quantityUsed = 0,
    required this.reorderLevel,
    required this.status,
    this.imagePath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  // Identity
  final String id;
  final String uuid;
  final String materialNumber; // MAT-YYYY-XXXX

  // Classification
  final String name;
  final MaterialCategory category;
  final String? customCategory; // used when category == custom

  // Linkages
  final String? projectId; // null = global inventory
  final String? vendorId;  // FK → vendors.id

  // Quantity & Units
  final String unit;
  final double unitPrice;
  final double quantityPurchased; // cumulative purchased
  final double quantityUsed;      // cumulative used

  // Stock alerts
  final double reorderLevel;
  final MaterialStatus status;

  // Optional
  final String? imagePath;
  final String? notes;

  // Audit
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  // ─── Computed Getters ──────────────────────────────────────────────────────

  double get quantityRemaining => quantityPurchased - quantityUsed;
  double get totalCost => quantityPurchased * unitPrice;
  bool get isLowStock =>
      quantityRemaining <= reorderLevel && quantityRemaining > 0;
  bool get isOutOfStock => quantityRemaining <= 0;

  String get formattedUnitPrice => AppFormatters.currency(unitPrice);
  String get formattedTotalCost => AppFormatters.currency(totalCost);
  String get displayCategory =>
      category == MaterialCategory.custom && customCategory != null
          ? customCategory!
          : categoryLabels[category] ?? category.name;

  // ─── Static Metadata ──────────────────────────────────────────────────────

  static const categoryLabels = <MaterialCategory, String>{
    MaterialCategory.cement: 'Cement',
    MaterialCategory.steel: 'Steel & Iron',
    MaterialCategory.bricks: 'Bricks & Blocks',
    MaterialCategory.sand: 'Sand & Aggregates',
    MaterialCategory.gravel: 'Gravel & Stone',
    MaterialCategory.timber: 'Timber & Wood',
    MaterialCategory.paint: 'Paint & Finishes',
    MaterialCategory.electrical: 'Electrical',
    MaterialCategory.plumbing: 'Plumbing',
    MaterialCategory.glass: 'Glass & Windows',
    MaterialCategory.tiles: 'Tiles & Flooring',
    MaterialCategory.hardware: 'Hardware & Fixtures',
    MaterialCategory.fuel: 'Fuel & Lubricants',
    MaterialCategory.other: 'Other',
    MaterialCategory.custom: 'Custom',
  };

  static const categoryIcons = <MaterialCategory, IconData>{
    MaterialCategory.cement: Icons.layers_outlined,
    MaterialCategory.steel: Icons.construction_outlined,
    MaterialCategory.bricks: Icons.widgets_outlined,
    MaterialCategory.sand: Icons.terrain_outlined,
    MaterialCategory.gravel: Icons.scatter_plot_outlined,
    MaterialCategory.timber: Icons.forest_outlined,
    MaterialCategory.paint: Icons.imagesearch_roller_outlined,
    MaterialCategory.electrical: Icons.electrical_services_outlined,
    MaterialCategory.plumbing: Icons.water_drop_outlined,
    MaterialCategory.glass: Icons.window_outlined,
    MaterialCategory.tiles: Icons.grid_on_outlined,
    MaterialCategory.hardware: Icons.hardware_outlined,
    MaterialCategory.fuel: Icons.local_gas_station_outlined,
    MaterialCategory.other: Icons.category_outlined,
    MaterialCategory.custom: Icons.edit_note_outlined,
  };

  static const statusLabels = <MaterialStatus, String>{
    MaterialStatus.available: 'Available',
    MaterialStatus.lowStock: 'Low Stock',
    MaterialStatus.outOfStock: 'Out of Stock',
    MaterialStatus.reserved: 'Reserved',
    MaterialStatus.discontinued: 'Discontinued',
  };

  static const List<String> predefinedUnits = [
    'Bags',
    'Tons',
    'Kg',
    'Liters',
    'Pieces',
    'Meters',
    'Feet',
    'Brass',
    'Coils',
    'Sets',
    'Rolls',
    'Bundles',
    'Sheets',
    'Boxes',
    'Drums',
    'Custom',
  ];

  // ─── Auto-compute status from quantities ──────────────────────────────────

  static MaterialStatus computeStatus(
    double remaining,
    double reorder,
    MaterialStatus current,
  ) {
    if (current == MaterialStatus.reserved ||
        current == MaterialStatus.discontinued) {
      return current;
    }
    if (remaining <= 0) return MaterialStatus.outOfStock;
    if (remaining <= reorder) return MaterialStatus.lowStock;
    return MaterialStatus.available;
  }

  // ─── Factory Constructor ──────────────────────────────────────────────────

  factory MaterialModel.create({
    required String name,
    required MaterialCategory category,
    String? customCategory,
    String? projectId,
    String? vendorId,
    required String unit,
    required double unitPrice,
    double quantityPurchased = 0,
    double quantityUsed = 0,
    required double reorderLevel,
    MaterialStatus? status,
    String? imagePath,
    String? notes,
  }) {
    final now = DateTime.now();
    final uid = const Uuid().v4();
    final matNum =
        'MAT-${now.year}-${uid.substring(0, 4).toUpperCase()}';

    final remaining = quantityPurchased - quantityUsed;
    final computedStatus = status ??
        MaterialModel.computeStatus(remaining, reorderLevel, MaterialStatus.available);

    return MaterialModel(
      id: uid,
      uuid: uid,
      materialNumber: matNum,
      name: name,
      category: category,
      customCategory: customCategory,
      projectId: projectId,
      vendorId: vendorId,
      unit: unit,
      unitPrice: unitPrice,
      quantityPurchased: quantityPurchased,
      quantityUsed: quantityUsed,
      reorderLevel: reorderLevel,
      status: computedStatus,
      imagePath: imagePath,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  // ─── copyWith ─────────────────────────────────────────────────────────────

  MaterialModel copyWith({
    String? name,
    MaterialCategory? category,
    String? customCategory,
    String? projectId,
    String? vendorId,
    String? unit,
    double? unitPrice,
    double? quantityPurchased,
    double? quantityUsed,
    double? reorderLevel,
    MaterialStatus? status,
    String? imagePath,
    String? notes,
    bool? isDeleted,
    // sentinel to allow clearing nullable fields
    bool clearCustomCategory = false,
    bool clearProjectId = false,
    bool clearVendorId = false,
    bool clearImagePath = false,
    bool clearNotes = false,
  }) {
    final newQtyPurchased = quantityPurchased ?? this.quantityPurchased;
    final newQtyUsed = quantityUsed ?? this.quantityUsed;
    final newReorder = reorderLevel ?? this.reorderLevel;
    final newStatus = status ??
        MaterialModel.computeStatus(
          newQtyPurchased - newQtyUsed,
          newReorder,
          this.status,
        );

    return MaterialModel(
      id: id,
      uuid: uuid,
      materialNumber: materialNumber,
      name: name ?? this.name,
      category: category ?? this.category,
      customCategory: clearCustomCategory ? null : (customCategory ?? this.customCategory),
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      vendorId: clearVendorId ? null : (vendorId ?? this.vendorId),
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      quantityPurchased: newQtyPurchased,
      quantityUsed: newQtyUsed,
      reorderLevel: newReorder,
      status: newStatus,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
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
      'materialNumber': materialNumber,
      'name': name,
      'category': category.name,
      'customCategory': customCategory,
      'projectId': projectId,
      'vendorId': vendorId,
      'unit': unit,
      'unitPrice': unitPrice,
      'quantityPurchased': quantityPurchased,
      'quantityUsed': quantityUsed,
      'reorderLevel': reorderLevel,
      'status': status.name,
      'imagePath': imagePath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'] as String,
      uuid: map['uuid'] as String? ?? map['id'] as String,
      materialNumber: map['materialNumber'] as String? ?? '',
      name: map['name'] as String,
      category: MaterialCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => MaterialCategory.other,
      ),
      customCategory: map['customCategory'] as String?,
      projectId: map['projectId'] as String?,
      vendorId: map['vendorId'] as String?,
      unit: map['unit'] as String? ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantityPurchased:
          (map['quantityPurchased'] as num?)?.toDouble() ?? 0.0,
      quantityUsed: (map['quantityUsed'] as num?)?.toDouble() ?? 0.0,
      reorderLevel: (map['reorderLevel'] as num?)?.toDouble() ?? 0.0,
      status: MaterialStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MaterialStatus.available,
      ),
      imagePath: map['imagePath'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isDeleted: (map['isDeleted'] as int? ?? 0) == 1,
    );
  }
}
