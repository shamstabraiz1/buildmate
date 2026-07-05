import 'package:uuid/uuid.dart';

enum AttendanceStatus { present, halfDay, absent, leave }

class AttendanceModel {
  const AttendanceModel({
    required this.id,
    required this.uuid,
    required this.projectId,
    required this.labourId,
    required this.date,
    required this.status,
    this.overtimeHours = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final String id;
  final String uuid;
  final String projectId;
  final String labourId;
  final DateTime date;
  final AttendanceStatus status;
  final double overtimeHours;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  static const statusLabels = {
    AttendanceStatus.present: 'Present',
    AttendanceStatus.halfDay: 'Half Day',
    AttendanceStatus.absent: 'Absent',
    AttendanceStatus.leave: 'Leave',
  };

  factory AttendanceModel.create({
    required String projectId,
    required String labourId,
    required DateTime date,
    required AttendanceStatus status,
    double overtimeHours = 0.0,
  }) {
    final now = DateTime.now();
    final uid = const Uuid().v4();
    
    return AttendanceModel(
      id: uid,
      uuid: uid,
      projectId: projectId,
      labourId: labourId,
      date: date,
      status: status,
      overtimeHours: overtimeHours,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  AttendanceModel copyWith({
    String? projectId,
    String? labourId,
    DateTime? date,
    AttendanceStatus? status,
    double? overtimeHours,
    bool? isDeleted,
  }) {
    return AttendanceModel(
      id: id,
      uuid: uuid,
      projectId: projectId ?? this.projectId,
      labourId: labourId ?? this.labourId,
      date: date ?? this.date,
      status: status ?? this.status,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'projectId': projectId,
      'labourId': labourId,
      'date': date.toIso8601String(),
      'status': status.name,
      'overtimeHours': overtimeHours,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] as String,
      uuid: map['uuid'] as String,
      projectId: map['projectId'] as String,
      labourId: map['labourId'] as String,
      date: DateTime.parse(map['date'] as String),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AttendanceStatus.present,
      ),
      overtimeHours: (map['overtimeHours'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }
}
