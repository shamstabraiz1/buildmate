import '../../data/models/attendance_model.dart';
import '../../data/models/labour_model.dart';

abstract class LabourRepository {
  Future<void> addLabour(LabourModel labour);
  Future<void> updateLabour(LabourModel labour);
  Future<void> deleteLabour(String id);
  Future<List<LabourModel>> getLabours();
  
  Future<void> markAttendance(AttendanceModel attendance);
  Future<void> updateAttendance(AttendanceModel attendance);
  Future<void> deleteAttendance(String id);
  Future<List<AttendanceModel>> getAttendanceForProject(String projectId);
  Future<List<AttendanceModel>> getAttendanceForLabour(String labourId);
  Future<List<AttendanceModel>> getAttendanceForLabourByProject(String labourId, String projectId);
}
