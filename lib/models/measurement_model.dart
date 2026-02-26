import 'package:json_annotation/json_annotation.dart';

part 'measurement_model.g.dart';

@JsonSerializable()
class CreateMeasurementRequestDto {
  final String? externalId;
  final String name;
  final Map<String, double> measurementValues;
  final String clientId;
  final String? companyId;
  final String? userId;

  CreateMeasurementRequestDto({
    this.externalId,
    required this.name,
    required this.measurementValues,
    required this.clientId,
    this.companyId,
    this.userId,
  });

  factory CreateMeasurementRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateMeasurementRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateMeasurementRequestDtoToJson(this);
}

@JsonSerializable()
class MeasurementResponseDto {
  final String id;
  final String name;
  final Map<String, double> measurementValues;
  final String clientId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? companyId;
  final String? userId;

  MeasurementResponseDto({
    required this.id,
    required this.name,
    required this.measurementValues,
    required this.clientId,
    required this.createdAt,
    required this.updatedAt,
    this.companyId,
    this.userId,
  });

  factory MeasurementResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MeasurementResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MeasurementResponseDtoToJson(this);
}
