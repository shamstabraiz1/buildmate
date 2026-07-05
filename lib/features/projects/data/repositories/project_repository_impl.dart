import 'package:flutter/foundation.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_local_data_source.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  const ProjectRepositoryImpl(this.localDataSource);

  final ProjectLocalDataSource localDataSource;

  @override
  Future<void> addProject(ProjectModel project) async {
    debugPrint('ProjectRepositoryImpl.addProject called');
    await localDataSource.insertProject(project);
    debugPrint('ProjectRepositoryImpl.addProject finished localDataSource.insertProject');
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    await localDataSource.updateProject(project);
  }

  @override
  Future<void> deleteProject(String id) async {
    await localDataSource.deleteProject(id);
  }

  @override
  Future<List<ProjectModel>> getAllProjects() async {
    return await localDataSource.getProjects();
  }

  @override
  Future<ProjectModel?> getProjectById(String id) async {
    return await localDataSource.getProjectById(id);
  }

  @override
  Future<List<ProjectModel>> searchProjects(String query) async {
    final all = await localDataSource.getProjects();
    final lowerQ = query.toLowerCase();
    return all.where((p) {
      return p.name.toLowerCase().contains(lowerQ) ||
          p.clientName.toLowerCase().contains(lowerQ) ||
          p.location.toLowerCase().contains(lowerQ);
    }).toList();
  }

  @override
  Future<List<ProjectModel>> getActiveProjects() async {
    final all = await localDataSource.getProjects();
    return all.where((p) => p.status == ProjectStatus.active).toList();
  }

  @override
  Future<List<ProjectModel>> getCompletedProjects() async {
    final all = await localDataSource.getProjects();
    return all.where((p) => p.status == ProjectStatus.completed).toList();
  }
}
