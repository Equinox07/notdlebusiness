// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: json['id'] as String?,
      companyId: json['companyId'] as String,
      clientId: json['clientId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] == null
          ? ProjectStatus.planning
          : Project._statusFromJson(json['status'] as String),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      completedDate: json['completedDate'] == null
          ? null
          : DateTime.parse(json['completedDate'] as String),
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      syncDate: json['syncDate'] == null
          ? null
          : DateTime.parse(json['syncDate'] as String),
      client: json['client'] == null
          ? null
          : ClientDto.fromJson(json['client'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'clientId': instance.clientId,
      'client': instance.client,
      'title': instance.title,
      'description': instance.description,
      'status': Project._statusToJson(instance.status),
      'startDate': instance.startDate?.toIso8601String(),
      'deadline': instance.deadline?.toIso8601String(),
      'completedDate': instance.completedDate?.toIso8601String(),
      'budget': instance.budget,
      'spent': instance.spent,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isSynced': instance.isSynced,
      'syncDate': instance.syncDate?.toIso8601String(),
    };

ProjectDto _$ProjectDtoFromJson(Map<String, dynamic> json) => ProjectDto(
      id: json['id'] as String?,
      companyId: json['companyId'] as String,
      clientId: json['clientId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: $enumDecodeNullable(_$ProjectStatusEnumMap, json['status']) ??
          ProjectStatus.planning,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      budget: (json['budget'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ProjectDtoToJson(ProjectDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'clientId': instance.clientId,
      'title': instance.title,
      'description': instance.description,
      'status': _$ProjectStatusEnumMap[instance.status]!,
      'startDate': instance.startDate?.toIso8601String(),
      'deadline': instance.deadline?.toIso8601String(),
      'budget': instance.budget,
    };

const _$ProjectStatusEnumMap = {
  ProjectStatus.planning: 'PLANNING',
  ProjectStatus.inProgress: 'IN_PROGRESS',
  ProjectStatus.onHold: 'ON_HOLD',
  ProjectStatus.completed: 'COMPLETED',
  ProjectStatus.cancelled: 'CANCELLED',
};
