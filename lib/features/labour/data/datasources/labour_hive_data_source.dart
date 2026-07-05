import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/attendance_model.dart';
import '../models/labour_model.dart';
import 'labour_local_data_source.dart';

class LabourHiveDataSourceImpl implements LabourLocalDataSource {
  static const String _laboursBoxName = 'labours_box';
  static const String _attendanceBoxName = 'attendance_box';

  Box<String>? _laboursBox;
  Box<String>? _attendanceBox;

  Future<void> _init() async {
    _laboursBox ??= await Hive.openBox<String>(_laboursBoxName);
    _attendanceBox ??= await Hive.openBox<String>(_attendanceBoxName);
  }

  @override
  Future<void> insertLabour(LabourModel labour) async {
    await _init();
    await _laboursBox!.put(labour.id, jsonEncode(labour.toMap()));
  }

  @override
  Future<void> updateLabour(LabourModel labour) async {
    await _init();
    await _laboursBox!.put(labour.id, jsonEncode(labour.toMap()));
  }

  @override
  Future<void> deleteLabour(String id) async {
    await _init();
    final jsonStr = _laboursBox!.get(id);
    if (jsonStr != null) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      map['isDeleted'] = 1;
      await _laboursBox!.put(id, jsonEncode(map));
    }
  }

  @override
  Future<List<LabourModel>> getLabours() async {
    await _init();
    final List<LabourModel> labours = [];
    for (final jsonStr in _laboursBox!.values) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final labour = LabourModel.fromMap(map);
      if (!labour.isDeleted) {
        labours.add(labour);
      }
    }
    labours.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return labours;
  }

  @override
  Future<void> insertAttendance(AttendanceModel attendance) async {
    await _init();
    await _attendanceBox!.put(attendance.id, jsonEncode(attendance.toMap()));
  }

  @override
  Future<void> updateAttendance(AttendanceModel attendance) async {
    await _init();
    await _attendanceBox!.put(attendance.id, jsonEncode(attendance.toMap()));
  }

  @override
  Future<void> deleteAttendance(String id) async {
    await _init();
    final jsonStr = _attendanceBox!.get(id);
    if (jsonStr != null) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      map['isDeleted'] = 1;
      await _attendanceBox!.put(id, jsonEncode(map));
    }
  }

  @override
  Future<List<AttendanceModel>> getAttendanceForProject(String projectId) async {
    await _init();
    final List<AttendanceModel> records = [];
    for (final jsonStr in _attendanceBox!.values) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final attendance = AttendanceModel.fromMap(map);
      if (!attendance.isDeleted && attendance.projectId == projectId) {
        records.add(attendance);
      }
    }
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  @override
  Future<List<AttendanceModel>> getAttendanceForLabour(String labourId) async {
    await _init();
    final List<AttendanceModel> records = [];
    for (final jsonStr in _attendanceBox!.values) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final attendance = AttendanceModel.fromMap(map);
      if (!attendance.isDeleted && attendance.labourId == labourId) {
        records.add(attendance);
      }
    }
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  @override
  Future<List<AttendanceModel>> getAttendanceForLabourByProject(String labourId, String projectId) async {
    await _init();
    final List<AttendanceModel> records = [];
    for (final jsonStr in _attendanceBox!.values) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final attendance = AttendanceModel.fromMap(map);
      if (!attendance.isDeleted && attendance.labourId == labourId && attendance.projectId == projectId) {
        records.add(attendance);
      }
    }
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }
}
