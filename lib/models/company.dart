// lib/models/company.dart

import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';

@Entity(tableName: 'company')
class Company {
  @PrimaryKey()
  final String id;
  final String businessName;
  final String ownerName;
  final String email;
  final String mobile;
  final int yearsOfExperience;
  final String registrationNumber;
  final String countryCode;
  final String address;
  final String? logoUrl;
  final String? imagePath;
  final bool active;
  final String currency;
  final String country;
  final String? deviceId;

  Company({
    String? id,
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.mobile,
    required this.yearsOfExperience,
    required this.registrationNumber,
    required this.countryCode,
    required this.address,
    this.logoUrl,
    this.imagePath,
    this.active = true,
    this.currency = 'GHS',
    this.country = 'Ghana',
    this.deviceId,
  }) : id = id ?? const Uuid().v4();

  // Factory constructor to create a Company from a Map
  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'] as String,
      businessName: map['businessName'] as String,
      ownerName: map['ownerName'] as String,
      email: map['email'] as String,
      mobile: map['mobile'] as String,
      yearsOfExperience: (map['yearsOfExperience'] as num).toInt(),
      registrationNumber: map['registrationNumber'] as String,
      countryCode: map['countryCode'] as String,
      address: map['address'] as String,
      logoUrl: map['logoUrl'] as String?,
      imagePath: map['imagePath'] as String?,
      active: map['active'] as bool? ?? true,
      currency: map['currency'] as String? ?? 'GHS',
      country: map['country'] as String? ?? 'Ghana',
      deviceId: map['deviceId'] as String?,
    );
  }

  // Method to convert a Company object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessName': businessName,
      'ownerName': ownerName,
      'email': email,
      'mobile': mobile,
      'yearsOfExperience': yearsOfExperience,
      'registrationNumber': registrationNumber,
      'countryCode': countryCode,
      'address': address,
      'logoUrl': logoUrl,
      'imagePath': imagePath,
      'active': active,
      'currency': currency,
      'country': country,
      'deviceId': deviceId,
    };
  }

  Company copyWith({
    String? id,
    String? businessName,
    String? ownerName,
    String? email,
    String? mobile,
    int? yearsOfExperience,
    String? registrationNumber,
    String? countryCode,
    String? address,
    String? logoUrl,
    String? imagePath,
    bool? active,
    String? currency,
    String? country,
    String? deviceId,
  }) {
    return Company(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      countryCode: countryCode ?? this.countryCode,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      imagePath: imagePath ?? this.imagePath,
      active: active ?? this.active,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
