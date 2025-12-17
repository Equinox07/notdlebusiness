import 'package:floor/floor.dart';

import '../../models/project_model.dart';

@dao
abstract class ProjectDao {
  @Query('SELECT * FROM projects WHERE id = :id')
  Future<Project?> getProjectById(String id);

  @Query(
    'SELECT * FROM projects WHERE company_id = :companyId ORDER BY updated_at DESC',
  )
  Future<List<Project>> getProjectsByCompany(String companyId);

  @Query('''
    SELECT * FROM projects 
    WHERE company_id = :companyId 
    AND (title LIKE '%' || :query || '%' OR description LIKE '%' || :query || '%')
    ORDER BY updated_at DESC
  ''')
  Future<List<Project>> searchProjects(String companyId, String query);

  @Query('''
    SELECT * FROM projects 
    WHERE company_id = :companyId 
    AND status = :status
    ORDER BY updated_at DESC
  ''')
  Future<List<Project>> getProjectsByStatus(String companyId, String status);

  @Query('''
    SELECT * FROM projects 
    WHERE company_id = :companyId 
    AND deadline < :date
    AND status NOT IN ('COMPLETED', 'CANCELLED')
    ORDER BY deadline ASC
  ''')
  Future<List<Project>> getOverdueProjects(String companyId, DateTime date);

  @Query('''
    SELECT * FROM projects 
    WHERE company_id = :companyId 
    AND deadline BETWEEN :startDate AND :endDate
    ORDER BY deadline ASC
  ''')
  Future<List<Project>> getProjectsDueBetween(
    String companyId,
    DateTime startDate,
    DateTime endDate,
  );

  @Query(
    'SELECT * FROM projects WHERE client_id = :clientId ORDER BY updated_at DESC',
  )
  Future<List<Project>> getProjectsByClient(String clientId);

  @insert
  Future<void> insertProject(Project project);

  @update
  Future<void> updateProject(Project project);

  @delete
  Future<void> deleteProject(Project project);

  @Query('DELETE FROM projects WHERE id = :id')
  Future<void> deleteProjectById(String id);

  @Query('DELETE FROM projects WHERE company_id = :companyId')
  Future<void> deleteProjectsByCompany(String companyId);

  @Query('SELECT COUNT(*) FROM projects WHERE company_id = :companyId')
  Future<int?> countProjects(String companyId);
}
