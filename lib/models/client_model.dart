import 'package:json_annotation/json_annotation.dart';

part 'client_model.g.dart';

@JsonSerializable()
class ClientDto {
  final String? id;
  final String? externalId;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String? companyId;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClientDto({
    this.id,
    this.externalId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    this.companyId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory ClientDto.fromJson(Map<String, dynamic> json) =>
      _$ClientDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ClientDtoToJson(this);
}
