import 'package:flutter/material.dart';
import 'package:notdle/models/project_model.dart';
import 'package:notdle/models/repository/project_repository.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectRepository _projectRepository;
  
  ProjectProvider({required ProjectRepository projectRepository}) 
      : _projectRepository = projectRepository;

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  List<Project> _projects = [];
  List<Project> get projects => _projects;
  
  Project? _selectedProject;
  Project? get selectedProject => _selectedProject;
  
  // Project status filter
  ProjectStatus? _statusFilter;
  ProjectStatus? get statusFilter => _statusFilter;
  
  // Search query
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Initialize provider
  Future<void> initialize(String companyId) async {
    await _loadProjects(companyId);
  }

  // Load projects with optional filtering
  Future<void> _loadProjects(String companyId, {bool forceRefresh = false}) async {
    _setLoading(true);
    _error = null;
    
    try {
      if (forceRefresh) {
        // Force refresh from remote
        await _projectRepository.fetchProjects(companyId);
      }
      
      // Get projects based on current filters
      if (_statusFilter != null) {
        _projects = await _projectRepository.getProjectsByStatus(companyId, _statusFilter!.name);
      } else if (_searchQuery.isNotEmpty) {
        _projects = await _projectRepository.searchLocalProjects(companyId, _searchQuery);
      } else {
        _projects = await _projectRepository.getLocalProjects(companyId);
      }
      
      _projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load projects: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Set status filter
  void setStatusFilter(ProjectStatus? status) {
    _statusFilter = status;
    _searchQuery = ''; // Clear search when applying status filter
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _statusFilter = null; // Clear status filter when searching
    notifyListeners();
  }

  // Get project by ID
  Future<Project?> getProjectById(String id) async {
    try {
      return await _projectRepository.getLocalProjectById(id);
    } catch (e) {
      _error = 'Failed to load project: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Select project
  void selectProject(Project project) {
    _selectedProject = project;
    notifyListeners();
  }

  // Clear selected project
  void clearSelectedProject() {
    _selectedProject = null;
    notifyListeners();
  }

  // Create new project
  Future<Project> createProject(ProjectDto dto) async {
    _setLoading(true);
    _error = null;
    
    try {
      final project = await _projectRepository.createProject(dto);
      await _loadProjects(dto.companyId);
      return project;
    } catch (e) {
      _error = 'Failed to create project: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update project
  Future<void> updateProject(ProjectDto dto) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _projectRepository.updateProject(dto);
      await _loadProjects(dto.companyId);
    } catch (e) {
      _error = 'Failed to update project: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete project
  Future<void> deleteProject(String companyId, String projectId) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _projectRepository.deleteProject(companyId, projectId);
      await _loadProjects(companyId);
    } catch (e) {
      _error = 'Failed to delete project: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh projects
  Future<void> refreshProjects(String companyId) async {
    await _loadProjects(companyId, forceRefresh: true);
  }

  // Get projects by status
  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async {
    try {
      return await _projectRepository.getProjectsByStatus(
        _selectedProject?.companyId ?? '',
        status.name,
      );
    } catch (e) {
      _error = 'Failed to filter projects: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  // Get active projects
  Future<List<Project>> getActiveProjects(String companyId) async {
    try {
      return await _projectRepository.getActiveProjects(companyId);
    } catch (e) {
      _error = 'Failed to get active projects: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  // Get overdue projects
  Future<List<Project>> getOverdueProjects(String companyId) async {
    try {
      return await _projectRepository.getOverdueProjects(companyId);
    } catch (e) {
      _error = 'Failed to get overdue projects: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  // Get project financials
  Future<Map<String, dynamic>> getProjectFinancials(String companyId) async {
    try {
      return await _projectRepository.getProjectFinancials(companyId);
    } catch (e) {
      _error = 'Failed to get project financials: ${e.toString()}';
      notifyListeners();
      return {};
    }
  }

  // Sync projects with remote
  Future<void> syncProjects(String companyId) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _projectRepository.syncLocalProjects(companyId);
      await _loadProjects(companyId, forceRefresh: true);
    } catch (e) {
      _error = 'Failed to sync projects: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to update loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
