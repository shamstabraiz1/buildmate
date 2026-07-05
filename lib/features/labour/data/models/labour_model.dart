import 'package:uuid/uuid.dart';

enum LabourRole { mason, carpenter, painter, electrician, plumber, helper, siteSupervisor, custom }
enum LabourStatus { active, inactive }

class LabourModel {
  const LabourModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.phone,
    required this.role,
    required this.dailyRate,
    this.status = LabourStatus.active,
    this.cnic,
    this.address,
    this.overtimeRate,
    this.imagePath,
    this.customRole,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final String id;
  final String uuid;
  final String name;
  final String phone;
  final LabourRole role;
  final double dailyRate;
  
  final LabourStatus status;
  final String? cnic;
  final String? address;
  final double? overtimeRate;
  final String? imagePath;
  final String? customRole;
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  String get formattedWage => 'Rs. ${dailyRate.toStringAsFixed(0)}/day';

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
  }

  static const roleLabels = {
    LabourRole.mason: 'Mason',
    LabourRole.carpenter: 'Carpenter',
    LabourRole.painter: 'Painter',
    LabourRole.electrician: 'Electrician',
    LabourRole.plumber: 'Plumber',
    LabourRole.helper: 'Helper',
    LabourRole.siteSupervisor: 'Site Supervisor',
    LabourRole.custom: 'Custom',
  };

  static const statusLabels = {
    LabourStatus.active: 'Active',
    LabourStatus.inactive: 'Inactive',
  };

  factory LabourModel.create({
    required String name,
    required String phone,
    required LabourRole role,
    required double dailyRate,
    LabourStatus status = LabourStatus.active,
    String? cnic,
    String? address,
    double? overtimeRate,
    String? imagePath,
    String? customRole,
    String? notes,
  }) {
    final now = DateTime.now();
    final uid = const Uuid().v4();
    
    return LabourModel(
      id: uid,
      uuid: uid,
      name: name,
      phone: phone,
      role: role,
      dailyRate: dailyRate,
      status: status,
      cnic: cnic,
      address: address,
      overtimeRate: overtimeRate,
      imagePath: imagePath,
      customRole: customRole,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  LabourModel copyWith({
    String? name,
    String? phone,
    LabourRole? role,
    double? dailyRate,
    LabourStatus? status,
    String? cnic,
    String? address,
    double? overtimeRate,
    String? imagePath,
    String? customRole,
    String? notes,
    bool? isDeleted,
  }) {
    return LabourModel(
      id: id,
      uuid: uuid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      dailyRate: dailyRate ?? this.dailyRate,
      status: status ?? this.status,
      cnic: cnic ?? this.cnic,
      address: address ?? this.address,
      overtimeRate: overtimeRate ?? this.overtimeRate,
      imagePath: imagePath ?? this.imagePath,
      customRole: customRole ?? this.customRole,
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
      'phone': phone,
      'role': role.name,
      'dailyRate': dailyRate,
      'status': status.name,
      'cnic': cnic,
      'address': address,
      'overtimeRate': overtimeRate,
      'imagePath': imagePath,
      'customRole': customRole,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory LabourModel.fromMap(Map<String, dynamic> map) {
    return LabourModel(
      id: map['id'] as String,
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String? ?? '',
      role: LabourRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => LabourRole.helper,
      ),
      dailyRate: (map['dailyRate'] as num).toDouble(),
      status: LabourStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LabourStatus.active,
      ),
      cnic: map['cnic'] as String?,
      address: map['address'] as String?,
      overtimeRate: map['overtimeRate'] != null ? (map['overtimeRate'] as num).toDouble() : null,
      imagePath: map['imagePath'] as String?,
      customRole: map['customRole'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }
}
