import '../../../../core/database/database_helper.dart';
import '../models/attendance_model.dart';
import '../models/labour_model.dart';

abstract class LabourLocalDataSource {
  Future<void> insertLabour(LabourModel labour);
  Future<void> updateLabour(LabourModel labour);
  Future<void> deleteLabour(String id);
  Future<List<LabourModel>> getLabours();
  
  Future<void> insertAttendance(AttendanceModel attendance);
  Future<void> updateAttendance(AttendanceModel attendance);
  Future<void> deleteAttendance(String id);
  Future<List<AttendanceModel>> getAttendanceForProject(String projectId);
  Future<List<AttendanceModel>> getAttendanceForLabour(String labourId);
  Future<List<AttendanceModel>> getAttendanceForLabourByProject(String labourId, String projectId);
}

class LabourLocalDataSourceImpl implements LabourLocalDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  Future<void> insertLabour(LabourModel labour) async {
    final db = await _databaseHelper.database;
    await db.insert('labours', labour.toMap());
  }

  @override
  Future<void> updateLabour(LabourModel labour) async {
    final db = await _databaseHelper.database;
    await db.update(
      'labours',
      labour.toMap(),
      where: 'id = ?',
      whereArgs: [labour.id],
    );
  }

  @override
  Future<void> deleteLabour(String id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'labours',
      {'isDeleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<LabourModel>> getLabours() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'labours',
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => LabourModel.fromMap(map)).toList();
  }

  @override
  Future<void> insertAttendance(AttendanceModel attendance) async {
    final db = await _databaseHelper.database;
    await db.insert('attendance', attendance.toMap());
  }

  @override
  Future<void> updateAttendance(AttendanceModel attendance) async {
    final db = await _databaseHelper.database;
    await db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  @override
  Future<void> deleteAttendance(String id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'attendance',
      {'isDeleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<AttendanceModel>> getAttendanceForProject(String projectId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'attendance',
      where: 'projectId = ? AND isDeleted = ?',
      whereArgs: [projectId, 0],
      orderBy: 'date DESC',
    );
    return maps.map((e) => AttendanceModel.fromMap(e)).toList();
  }

  @override
  Future<List<AttendanceModel>> getAttendanceForLabour(String labourId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'attendance',
      where: 'labourId = ? AND isDeleted = ?',
      whereArgs: [labourId, 0],
      orderBy: 'date DESC',
    );
    return maps.map((e) => AttendanceModel.fromMap(e)).toList();
  }

  @override
  Future<List<AttendanceModel>> getAttendanceForLabourByProject(String labourId, String projectId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'attendance',
      where: 'labourId = ? AND projectId = ? AND isDeleted = ?',
      whereArgs: [labourId, projectId, 0],
      orderBy: 'date DESC',
    );
    return maps.map((e) => AttendanceModel.fromMap(e)).toList();
  }
}
