import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/labour_model.dart';
import '../../data/repositories/labour_repository_impl.dart';
import '../../domain/repositories/labour_repository.dart';

final labourRepositoryProvider = Provider<LabourRepository>((ref) {
  return LabourRepositoryImpl();
});

class LaboursNotifier extends AsyncNotifier<List<LabourModel>> {
  @override
  FutureOr<List<LabourModel>> build() async {
    return _fetchLabours();
  }

  Future<List<LabourModel>> _fetchLabours() async {
    final repo = ref.read(labourRepositoryProvider);
    return await repo.getLabours();
  }

  Future<void> addLabour(LabourModel labour) async {
    final repo = ref.read(labourRepositoryProvider);
    await repo.addLabour(labour);
    ref.invalidateSelf();
  }

  Future<void> updateLabour(LabourModel labour) async {
    final repo = ref.read(labourRepositoryProvider);
    await repo.updateLabour(labour);
    ref.invalidateSelf();
  }

  Future<void> deleteLabour(String id) async {
    final repo = ref.read(labourRepositoryProvider);
    await repo.deleteLabour(id);
    ref.invalidateSelf();
  }
}

final laboursNotifierProvider = AsyncNotifierProvider<LaboursNotifier, List<LabourModel>>(() {
  return LaboursNotifier();
});

class AttendanceNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> markAttendance(AttendanceModel attendance) async {
    final repo = ref.read(labourRepositoryProvider);
    await repo.markAttendance(attendance);
    ref.invalidate(attendanceNotifierProvider(attendance.labourId));
    ref.invalidate(projectAttendanceProvider(attendance.projectId));
  }

  Future<void> updateAttendance(AttendanceModel attendance) async {
    final repo = ref.read(labourRepositoryProvider);
    await repo.updateAttendance(attendance);
    ref.invalidate(attendanceNotifierProvider(attendance.labourId));
    ref.invalidate(projectAttendanceProvider(attendance.projectId));
  }

  Future<void> deleteAttendance(String id, String labourId, String projectId) async {
    final repo = ref.read(labourRepositoryProvider);
    await repo.deleteAttendance(id);
    ref.invalidate(attendanceNotifierProvider(labourId));
    ref.invalidate(projectAttendanceProvider(projectId));
  }
}

final attendanceMutationProvider = AsyncNotifierProvider<AttendanceNotifier, void>(() {
  return AttendanceNotifier();
});

final attendanceNotifierProvider = FutureProvider.family<List<AttendanceModel>, String>((ref, labourId) async {
  final repo = ref.read(labourRepositoryProvider);
  return await repo.getAttendanceForLabour(labourId);
});

final projectAttendanceProvider = FutureProvider.family<List<AttendanceModel>, String>((ref, projectId) async {
  final repo = ref.read(labourRepositoryProvider);
  return await repo.getAttendanceForProject(projectId);
});
