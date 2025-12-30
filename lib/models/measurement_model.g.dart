// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateMeasurementRequestDto _$CreateMeasurementRequestDtoFromJson(
        Map<String, dynamic> json) =>
    CreateMeasurementRequestDto(
      externalId: json['externalId'] as String?,
      name: json['name'] as String,
      measurementValues:
          (json['measurementValues'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      clientId: json['clientId'] as String,
    );

Map<String, dynamic> _$CreateMeasurementRequestDtoToJson(
        CreateMeasurementRequestDto instance) =>
    <String, dynamic>{
      'externalId': instance.externalId,
      'name': instance.name,
      'measurementValues': instance.measurementValues,
      'clientId': instance.clientId,
    };

MeasurementResponseDto _$MeasurementResponseDtoFromJson(
        Map<String, dynamic> json) =>
    MeasurementResponseDto(
      id: json['id'] as String,
      name: json['name'] as String,
      measurementValues:
          (json['measurementValues'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      clientId: json['clientId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MeasurementResponseDtoToJson(
        MeasurementResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'measurementValues': instance.measurementValues,
      'clientId': instance.clientId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
