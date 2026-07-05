import 'package:uuid/uuid.dart';

enum ProjectStatus { active, onHold, completed, planning }
enum ProjectSortOption { nameAsc, nameDesc, budgetHigh, budgetLow, progressHigh, progressLow, newest, oldest }

class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.clientName,
    required this.location,
    required this.budget,
    required this.amountSpent,
    required this.progress,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final String id;
  final String uuid;
  final String name;
  final String clientName;
  final String location;
  final double budget;
  final double amountSpent;
  final double progress;
  final ProjectStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  String get formattedBudget => _formatAmount(budget);
  String get formattedSpent => _formatAmount(amountSpent);
  String get progressPercent => '${(progress * 100).round()}%';

  static const statusLabels = {
    ProjectStatus.active:    'Active',
    ProjectStatus.onHold:    'On Hold',
    ProjectStatus.completed: 'Completed',
    ProjectStatus.planning:  'Planning',
  };

  static const sortLabels = {
    ProjectSortOption.nameAsc:       'Name (A–Z)',
    ProjectSortOption.nameDesc:      'Name (Z–A)',
    ProjectSortOption.budgetHigh:    'Budget (High)',
    ProjectSortOption.budgetLow:     'Budget (Low)',
    ProjectSortOption.progressHigh:  'Progress (High)',
    ProjectSortOption.progressLow:   'Progress (Low)',
    ProjectSortOption.newest:        'Newest First',
    ProjectSortOption.oldest:        'Oldest First',
  };

  static String _formatAmount(double v) {
    if (v >= 10000000) return '₹ ${(v / 10000000).toStringAsFixed(1)} Cr';
    if (v >= 100000) return '₹ ${(v / 100000).toStringAsFixed(1)} L';
    return '₹ ${v.toStringAsFixed(0)}';
  }

  factory ProjectModel.create({
    required String name,
    required String clientName,
    required String location,
    required double budget,
    required DateTime startDate,
    required DateTime endDate,
    required String description,
  }) {
    final now = DateTime.now();
    final uid = const Uuid().v4();
    return ProjectModel(
      id: uid,
      uuid: uid,
      name: name,
      clientName: clientName,
      location: location,
      budget: budget,
      amountSpent: 0.0,
      progress: 0.0,
      status: ProjectStatus.planning,
      startDate: startDate,
      endDate: endDate,
      description: description,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  ProjectModel copyWith({
    String? name,
    String? clientName,
    String? location,
    double? budget,
    double? amountSpent,
    double? progress,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    bool? isDeleted,
  }) {
    return ProjectModel(
      id: id,
      uuid: uuid,
      name: name ?? this.name,
      clientName: clientName ?? this.clientName,
      location: location ?? this.location,
      budget: budget ?? this.budget,
      amountSpent: amountSpent ?? this.amountSpent,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(), // Auto update on copy
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'clientName': clientName,
      'location': location,
      'budget': budget,
      'amountSpent': amountSpent,
      'progress': progress,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String,
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      clientName: map['clientName'] as String,
      location: map['location'] as String,
      budget: (map['budget'] as num).toDouble(),
      amountSpent: (map['amountSpent'] as num).toDouble(),
      progress: (map['progress'] as num).toDouble(),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ProjectStatus.planning,
      ),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      description: map['description'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }
}
