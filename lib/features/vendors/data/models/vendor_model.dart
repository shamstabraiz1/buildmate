import 'package:uuid/uuid.dart';

class VendorModel {
  const VendorModel({
    required this.id,
    required this.uuid,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.rating = 0.0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final String id;
  final String uuid;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final double rating; // 0.0 – 5.0
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
  }

  String get formattedRating => rating > 0 ? rating.toStringAsFixed(1) : 'N/A';

  factory VendorModel.create({
    required String name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    double rating = 0.0,
    String? notes,
  }) {
    final now = DateTime.now();
    final uid = const Uuid().v4();
    return VendorModel(
      id: uid,
      uuid: uid,
      name: name,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      address: address,
      rating: rating,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  VendorModel copyWith({
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    double? rating,
    String? notes,
    bool? isDeleted,
  }) {
    return VendorModel(
      id: id,
      uuid: uuid,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'rating': rating,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory VendorModel.fromMap(Map<String, dynamic> map) {
    return VendorModel(
      id: map['id'] as String,
      uuid: map['uuid'] as String? ?? map['id'] as String,
      name: map['name'] as String,
      contactPerson: map['contactPerson'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      rating:
          map['rating'] != null ? (map['rating'] as num).toDouble() : 0.0,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isDeleted: (map['isDeleted'] as int? ?? 0) == 1,
    );
  }
}
