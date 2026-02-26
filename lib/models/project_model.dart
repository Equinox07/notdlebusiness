import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'client_model.dart';

part 'project_model.g.dart';

enum ProjectStatus {
  @JsonValue('PLANNING')
  planning,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('ON_HOLD')
  onHold,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
}

@JsonSerializable()
@Entity(tableName: 'projects')
class Project extends Equatable {
  @PrimaryKey()
  final String id;

  @ColumnInfo(name: 'company_id')
  final String companyId;

  @ColumnInfo(name: 'client_id')
  final String clientId;

  @ignore
  ClientDto? client;

  final String title;
  final String? description;

  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  @ColumnInfo(name: 'status')
  final ProjectStatus status;

  @ColumnInfo(name: 'start_date')
  final DateTime? startDate;

  @ColumnInfo(name: 'deadline')
  final DateTime? deadline;

  @ColumnInfo(name: 'completed_date')
  final DateTime? completedDate;

  @ColumnInfo(name: 'budget')
  final double budget;

  @ColumnInfo(name: 'spent')
  final double spent;

  @ColumnInfo(name: 'created_at')
  final DateTime createdAt;

  @ColumnInfo(name: 'updated_at')
  final DateTime updatedAt;

  @ColumnInfo(name: 'is_synced')
  final bool isSynced;

  @ColumnInfo(name: 'sync_date')
  final DateTime? syncDate;

  @ColumnInfo(name: 'user_id')
  final String? userId;

  Project({
    String? id,
    required this.companyId,
    required this.clientId,
    required this.title,
    this.description,
    this.status = ProjectStatus.planning,
    this.startDate,
    this.deadline,
    this.completedDate,
    this.budget = 0.0,
    this.spent = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = false,
    this.syncDate,
    this.client,
    this.userId,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // JSON serialization
  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  // Status conversion helpers
  static ProjectStatus _statusFromJson(String status) {
    return ProjectStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status.toLowerCase(),
      orElse: () => ProjectStatus.planning,
    );
  }

  static String _statusToJson(ProjectStatus status) =>
      status.toString().split('.').last;

  // Copy with method for immutability
  Project copyWith({
    String? id,
    String? companyId,
    String? clientId,
    ClientDto? client,
    String? title,
    String? description,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? deadline,
    DateTime? completedDate,
    double? budget,
    double? spent,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    DateTime? syncDate,
    String? userId,
  }) {
    return Project(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      clientId: clientId ?? this.clientId,
      client: client ?? this.client,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      completedDate: completedDate ?? this.completedDate,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSynced: isSynced ?? this.isSynced,
      syncDate: syncDate ?? this.syncDate,
      userId: userId ?? this.userId,
    );
  }

  // Equatable props
  @override
  List<Object?> get props => [
    id,
    companyId,
    clientId,
    title,
    description,
    status,
    startDate,
    deadline,
    completedDate,
    budget,
    spent,
    createdAt,
    updatedAt,
    isSynced,
    syncDate,
    userId,
  ];

  // Helper methods
  double get progress {
    if (status == ProjectStatus.completed) return 1.0;
    if (status == ProjectStatus.cancelled) return 0.0;
    if (budget <= 0) return 0.0;
    return (spent / budget).clamp(0.0, 1.0);
  }

  bool get isOverdue =>
      deadline != null &&
      status != ProjectStatus.completed &&
      status != ProjectStatus.cancelled &&
      deadline!.isBefore(DateTime.now());

  bool get isActive =>
      status == ProjectStatus.planning || status == ProjectStatus.inProgress;
}

// DTO for creating/updating projects
@JsonSerializable()
class ProjectDto {
  final String? id;
  final String companyId;
  final String clientId;
  final String title;
  final String? description;
  final ProjectStatus status;
  final DateTime? startDate;
  final DateTime? deadline;
  final double? budget;
  final String? userId;

  ProjectDto({
    this.id,
    required this.companyId,
    required this.clientId,
    required this.title,
    this.description,
    this.status = ProjectStatus.planning,
    this.startDate,
    this.deadline,
    this.budget,
    this.userId,
  });

  factory ProjectDto.fromProject(Project project) => ProjectDto(
    id: project.id,
    companyId: project.companyId,
    clientId: project.clientId,
    title: project.title,
    description: project.description,
    status: project.status,
    startDate: project.startDate,
    deadline: project.deadline,
    budget: project.budget,
    userId: project.userId,
  );

  factory ProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectDtoToJson(this);
}

// Extension for mapping between entities and DTOs
extension ProjectX on Project {
  ProjectDto toDto() => ProjectDto.fromProject(this);
}

extension ProjectDtoX on ProjectDto {
  Project toProject() => Project(
    id: id,
    companyId: companyId,
    clientId: clientId,
    title: title,
    description: description,
    status: status,
    startDate: startDate,
    deadline: deadline,
    budget: budget ?? 0.0,
    userId: userId,
  );
}
