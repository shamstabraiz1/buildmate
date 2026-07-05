import '../../data/models/project_model.dart';

abstract class ProjectRepository {
  Future<void> addProject(ProjectModel project);
  Future<void> updateProject(ProjectModel project);
  Future<void> deleteProject(String id);
  Future<List<ProjectModel>> getAllProjects();
  Future<ProjectModel?> getProjectById(String id);
  Future<List<ProjectModel>> searchProjects(String query);
  Future<List<ProjectModel>> getActiveProjects();
  Future<List<ProjectModel>> getCompletedProjects();
}
