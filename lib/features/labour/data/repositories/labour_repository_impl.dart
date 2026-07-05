import 'package:flutter/foundation.dart';
import '../../domain/repositories/labour_repository.dart';
import '../datasources/labour_hive_data_source.dart';
import '../datasources/labour_local_data_source.dart';
import '../models/attendance_model.dart';
import '../models/labour_model.dart';

class LabourRepositoryImpl implements LabourRepository {
  LabourRepositoryImpl() {
    _dataSource = kIsWeb ? LabourHiveDataSourceImpl() : LabourLocalDataSourceImpl();
  }

  late final LabourLocalDataSource _dataSource;

  @override
  Future<void> addLabour(LabourModel labour) async {
    await _dataSource.insertLabour(labour);
  }

  @override
  Future<void> updateLabour(LabourModel labour) async {
    await _dataSource.updateLabour(labour);
  }

  @override
  Future<void> deleteLabour(String id) async {
    await _dataSource.deleteLabour(id);
  }

  @override
  Future<List<LabourModel>> getLabours() async {
    return await _dataSource.getLabours();
  }

  @override
  Future<void> markAttendance(AttendanceModel attendance) async {
    await _dataSource.insertAttendance(attendance);
  }

  @override
  Future<void> updateAttendance(AttendanceModel attendance) async {
    await _dataSource.updateAttendance(attendance);
  }

  @override
  Future<void> deleteAttendance(String id) async {
    await _dataSource.deleteAttendance(id);
  }

  @override
  Future<List<AttendanceModel>> getAttendanceForProject(String projectId) async {
    return await _dataSource.getAttendanceForProject(projectId);
  }

  @override
  Future<List<AttendanceModel>> getAttendanceForLabour(String labourId) async {
    return await _dataSource.getAttendanceForLabour(labourId);
  }

  @override
  Future<List<AttendanceModel>> getAttendanceForLabourByProject(String labourId, String projectId) async {
    return await _dataSource.getAttendanceForLabourByProject(labourId, projectId);
  }
}
