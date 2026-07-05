import 'package:flutter/foundation.dart';
import '../../../../../core/database/database_helper.dart';
import '../models/project_model.dart';

abstract class ProjectLocalDataSource {
  Future<void> insertProject(ProjectModel project);
  Future<void> updateProject(ProjectModel project);
  Future<void> deleteProject(String id);
  Future<List<ProjectModel>> getProjects();
  Future<ProjectModel?> getProjectById(String id);
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  ProjectLocalDataSourceImpl(this.dbHelper);

  final DatabaseHelper dbHelper;
  static const String tableName = 'projects';

  @override
  Future<void> insertProject(ProjectModel project) async {
    debugPrint('ProjectLocalDataSourceImpl.insertProject called');
    final db = await dbHelper.database;
    final id = await db.insert(tableName, project.toMap());
    debugPrint('ProjectLocalDataSourceImpl.insertProject inserted with id: $id');
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    final db = await dbHelper.database;
    await db.update(
      tableName,
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  @override
  Future<void> deleteProject(String id) async {
    final db = await dbHelper.database;
    // Soft delete implementation
    await db.update(
      tableName,
      {
        'isDeleted': 1,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<ProjectModel>> getProjects() async {
    final db = await dbHelper.database;
    // Only return projects that are not soft-deleted
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'isDeleted = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => ProjectModel.fromMap(maps[i]));
  }

  @override
  Future<ProjectModel?> getProjectById(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ? AND isDeleted = ?',
      whereArgs: [id, 0],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return ProjectModel.fromMap(maps.first);
    }
    return null;
  }
}
