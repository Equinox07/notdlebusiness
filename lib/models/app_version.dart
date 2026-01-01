import 'package:json_annotation/json_annotation.dart';

part 'app_version.g.dart';

@JsonSerializable()
class AppVersionDto {
  final String? id;
  final String platform;
  final String version;
  final int buildNumber;
  final String? releaseNotes;
  final String? minVersion;
  final String? packageName;
  final bool? forceUpdate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppVersionDto({
    this.id,
    required this.platform,
    required this.version,
    required this.buildNumber,
    this.releaseNotes,
    this.minVersion,
    this.packageName,
    this.forceUpdate,
    this.createdAt,
    this.updatedAt,
  });

  factory AppVersionDto.fromJson(Map<String, dynamic> json) =>
      _$AppVersionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AppVersionDtoToJson(this);
}
