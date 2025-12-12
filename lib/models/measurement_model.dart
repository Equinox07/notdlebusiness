import 'package:json_annotation/json_annotation.dart';

part 'measurement_model.g.dart';

@JsonSerializable()
class CreateMeasurementRequestDto {
  final String name;
  final Map<String, double> measurementValues;
  final String clientId;

  CreateMeasurementRequestDto({
    required this.name,
    required this.measurementValues,
    required this.clientId,
  });

  factory CreateMeasurementRequestDto.fromJson(Map<String, dynamic> json) => _$CreateMeasurementRequestDtoFromJson(json);
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

  MeasurementResponseDto({
    required this.id,
    required this.name,
    required this.measurementValues,
    required this.clientId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MeasurementResponseDto.fromJson(Map<String, dynamic> json) => _$MeasurementResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MeasurementResponseDtoToJson(this);
}
