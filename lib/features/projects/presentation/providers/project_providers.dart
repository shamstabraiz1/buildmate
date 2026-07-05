import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_helper.dart';
import '../../data/datasources/project_local_data_source.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/repositories/project_repository.dart';
import '../../data/datasources/project_hive_data_source.dart';

// ─── Dependency Injection Providers ──────────────────────────────────────────

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final projectDataSourceProvider = Provider<ProjectLocalDataSource>((ref) {
  if (kIsWeb) {
    return ProjectHiveDataSourceImpl();
  }
  final dbHelper = ref.watch(databaseHelperProvider);
  return ProjectLocalDataSourceImpl(dbHelper);
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final dataSource = ref.watch(projectDataSourceProvider);
  return ProjectRepositoryImpl(dataSource);
});

// ─── State Management (AsyncNotifier) ────────────────────────────────────────

class ProjectsNotifier extends AsyncNotifier<List<ProjectModel>> {
  @override
  FutureOr<List<ProjectModel>> build() async {
    return _loadProjects();
  }

  Future<List<ProjectModel>> _loadProjects() async {
    final repo = ref.read(projectRepositoryProvider);
    final projects = await repo.getAllProjects();
    
    return projects;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadProjects());
  }

  Future<void> addProject(ProjectModel project) async {
    debugPrint('ProjectsNotifier.addProject called for ${project.name}');
    final repo = ref.read(projectRepositoryProvider);
    await repo.addProject(project);
    debugPrint('ProjectsNotifier.addProject finished repo.addProject');
    await refresh();
    debugPrint('ProjectsNotifier.addProject finished refresh');
  }

  Future<void> updateProject(ProjectModel project) async {
    final repo = ref.read(projectRepositoryProvider);
    await repo.updateProject(project);
    await refresh();
  }

  Future<void> deleteProject(String id) async {
    final repo = ref.read(projectRepositoryProvider);
    await repo.deleteProject(id);
    await refresh();
  }
}

final projectsNotifierProvider =
    AsyncNotifierProvider<ProjectsNotifier, List<ProjectModel>>(() {
  return ProjectsNotifier();
});

// ─── Single Project Provider ──────────────────────────────────────────────────

final projectDetailsProvider =
    FutureProvider.family<ProjectModel?, String>((ref, id) async {
  // If the list is loaded, we can get it from cache instantly
  final listState = ref.watch(projectsNotifierProvider);
  if (listState.hasValue) {
    try {
      return listState.value!.firstWhere((p) => p.id == id);
    } catch (_) {
      // Fall through to network/db fetch
    }
  }
  
  // Otherwise fetch from db
  final repo = ref.read(projectRepositoryProvider);
  return await repo.getProjectById(id);
});
