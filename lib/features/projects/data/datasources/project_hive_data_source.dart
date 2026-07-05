import 'package:hive_flutter/hive_flutter.dart';
import '../models/project_model.dart';
import 'project_local_data_source.dart';

class ProjectHiveDataSourceImpl implements ProjectLocalDataSource {
  ProjectHiveDataSourceImpl();

  static const String _boxName = 'projects';

  Future<Box> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  @override
  Future<void> insertProject(ProjectModel project) async {
    final box = await _box;
    await box.put(project.id, project.toMap());
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    final box = await _box;
    await box.put(project.id, project.toMap());
  }

  @override
  Future<void> deleteProject(String id) async {
    final box = await _box;
    final map = box.get(id);
    if (map != null) {
      // Soft delete by updating the isDeleted flag
      final Map<String, dynamic> updatedMap = Map<String, dynamic>.from(map);
      updatedMap['isDeleted'] = 1;
      updatedMap['updatedAt'] = DateTime.now().toIso8601String();
      await box.put(id, updatedMap);
    }
  }

  @override
  Future<List<ProjectModel>> getProjects() async {
    final box = await _box;
    final list = box.values.toList();
    
    // Only return projects that are not soft-deleted
    return list
        .map((e) => ProjectModel.fromMap(Map<String, dynamic>.from(e)))
        .where((p) => !p.isDeleted)
        .toList();
  }

  @override
  Future<ProjectModel?> getProjectById(String id) async {
    final box = await _box;
    final map = box.get(id);
    if (map != null) {
      final p = ProjectModel.fromMap(Map<String, dynamic>.from(map));
      if (!p.isDeleted) {
        return p;
      }
    }
    return null;
  }
}
