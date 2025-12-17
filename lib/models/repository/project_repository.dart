import 'dart:async';

import 'package:notdle/models/dao/project_dao.dart';
import 'package:notdle/models/project_model.dart';
import 'package:notdle/services/api_service.dart';

class ProjectRepository {
  final ProjectDao _localDataSource;
  final ApiService _apiService;

  ProjectRepository({
    required ProjectDao localDataSource,
    required ApiService apiService,
  }) : _localDataSource = localDataSource,
       _apiService = apiService;

  // Local data operations
  Future<List<Project>> getLocalProjects(String companyId) async {
    return _localDataSource.getProjectsByCompany(companyId);
  }

  Future<Project?> getLocalProjectById(String id) async {
    return _localDataSource.getProjectById(id);
  }

  Future<List<Project>> searchLocalProjects(
    String companyId,
    String query,
  ) async {
    return _localDataSource.searchProjects(companyId, query);
  }

  Future<List<Project>> getProjectsByStatus(
    String companyId,
    String status,
  ) async {
    return _localDataSource.getProjectsByStatus(companyId, status);
  }

  Future<void> saveProjectLocally(Project project) async {
    final existing = await _localDataSource.getProjectById(project.id);
    if (existing != null) {
      await _localDataSource.updateProject(project);
    } else {
      await _localDataSource.insertProject(project);
    }
  }

  Future<void> deleteLocalProject(String id) async {
    await _localDataSource.deleteProjectById(id);
  }

  // Remote data operations
  Future<List<Project>> fetchProjects(String companyId) async {
    try {
      final response = await _apiService.getCompanyProjects(companyId);
      final projects =
          (response['content'] as List)
              .map((json) => Project.fromJson(json))
              .toList();

      // Save to local database
      for (final project in projects) {
        await saveProjectLocally(
          project.copyWith(isSynced: true, syncDate: DateTime.now()),
        );
      }

      return projects;
    } catch (e) {
      // Fallback to local data if remote fetch fails
      return getLocalProjects(companyId);
    }
  }

  Future<Project> createProject(ProjectDto dto) async {
    try {
      final response = await _apiService.createProject(
        dto.companyId,
        dto.toJson(),
      );
      final project = Project.fromJson(response);
      await saveProjectLocally(
        project.copyWith(isSynced: true, syncDate: DateTime.now()),
      );
      return project;
    } catch (e) {
      // Save locally and mark as not synced
      final project = dto.toProject().copyWith(isSynced: false);
      await saveProjectLocally(project);
      rethrow;
    }
  }

  Future<Project> updateProject(ProjectDto dto) async {
    if (dto.id == null) throw Exception('Project ID is required for update');

    try {
      final response = await _apiService.updateProject(
        dto.companyId,
        dto.id!,
        dto.toJson(),
      );
      final project = Project.fromJson(response);
      await saveProjectLocally(
        project.copyWith(isSynced: true, syncDate: DateTime.now()),
      );
      return project;
    } catch (e) {
      // Update locally and mark as not synced
      final existing = await getLocalProjectById(dto.id!);
      if (existing != null) {
        final updated = existing.copyWith(
          title: dto.title,
          description: dto.description,
          status: dto.status,
          startDate: dto.startDate,
          deadline: dto.deadline,
          budget: dto.budget ?? existing.budget,
          updatedAt: DateTime.now(),
          isSynced: false,
        );
        await saveProjectLocally(updated);
        return updated;
      }
      rethrow;
    }
  }

  Future<void> deleteProject(String companyId, String projectId) async {
    try {
      await _apiService.deleteProject(companyId, projectId);
      await deleteLocalProject(projectId);
    } catch (e) {
      // Mark for deletion or handle offline scenario
      final project = await getLocalProjectById(projectId);
      if (project != null) {
        await saveProjectLocally(
          project.copyWith(
            status: ProjectStatus.cancelled,
            isSynced: false,
            updatedAt: DateTime.now(),
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> syncLocalProjects(String companyId) async {
    try {
      // Get all local unsynced projects
      final unsyncedProjects = await _localDataSource
          .getProjectsByCompany(companyId)
          .then((projects) => projects.where((p) => !p.isSynced).toList());

      for (final project in unsyncedProjects) {
        try {
          if (project.status == ProjectStatus.cancelled) {
            // Try to delete on server
            await _apiService.deleteProject(companyId, project.id);
            await deleteLocalProject(project.id);
          } else if (await _localDataSource.getProjectById(project.id) !=
              null) {
            // Update existing
            await _apiService.updateProject(
              companyId,
              project.id,
              project.toJson(),
            );
            await saveProjectLocally(
              project.copyWith(isSynced: true, syncDate: DateTime.now()),
            );
          } else {
            // Create new
            final response = await _apiService.createProject(
              companyId,
              project.toJson(),
            );
            await saveProjectLocally(
              Project.fromJson(
                response,
              ).copyWith(isSynced: true, syncDate: DateTime.now()),
            );
          }
        } catch (e) {
          // Skip this project and continue with others
          continue;
        }
      }
    } catch (e) {
      // Handle sync error
      rethrow;
    }
  }

  // Additional business logic methods
  Future<List<Project>> getActiveProjects(String companyId) async {
    final projects = await _localDataSource.getProjectsByCompany(companyId);
    return projects.where((p) => p.isActive).toList();
  }

  Future<List<Project>> getOverdueProjects(String companyId) async {
    return _localDataSource.getOverdueProjects(companyId, DateTime.now());
  }

  Future<Map<String, dynamic>> getProjectFinancials(String companyId) async {
    final projects = await _localDataSource.getProjectsByCompany(companyId);
    double totalBudget = 0.0;
    double totalSpent = 0.0;

    for (final project in projects) {
      totalBudget += project.budget;
      totalSpent += project.spent;
    }

    return {'total_budget': totalBudget, 'total_spent': totalSpent};
  }
}
