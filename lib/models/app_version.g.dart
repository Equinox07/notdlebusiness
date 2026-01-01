// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppVersionDto _$AppVersionDtoFromJson(Map<String, dynamic> json) =>
    AppVersionDto(
      id: json['id'] as String?,
      platform: json['platform'] as String,
      version: json['version'] as String,
      buildNumber: (json['buildNumber'] as num).toInt(),
      releaseNotes: json['releaseNotes'] as String?,
      minVersion: json['minVersion'] as String?,
      packageName: json['packageName'] as String?,
      forceUpdate: json['forceUpdate'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AppVersionDtoToJson(AppVersionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'platform': instance.platform,
      'version': instance.version,
      'buildNumber': instance.buildNumber,
      'releaseNotes': instance.releaseNotes,
      'minVersion': instance.minVersion,
      'packageName': instance.packageName,
      'forceUpdate': instance.forceUpdate,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
