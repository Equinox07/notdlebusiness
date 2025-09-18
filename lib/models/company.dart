// lib/models/company.dart

import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

@Entity(
  tableName: 'company'
)
class Company {
  @PrimaryKey()
  final String id;
  final String fullName;
  final String email;
  final String mobile;
  final String businessName;
  final int yearsOfExperience;
  final String registrationNumber;
  final String address;
  final String countryCode; // New field for the country code
  final String? imagePath; // New: Local path to the company's logo
  final String? imageUrl;  // New: Remote URL for the company's logo

  Company({
    String? id,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.businessName,
    required this.yearsOfExperience,
    required this.registrationNumber,
    required this.address,
    required this.countryCode, // Add to the constructor
    this.imagePath,
    this.imageUrl,
  }) : id = id ?? uuid.v4();

  // Factory constructor to create a Company from a Map
  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      mobile: map['mobile'] as String,
      businessName: map['businessName'] as String,
      yearsOfExperience: map['yearsOfExperience'] as int,
      registrationNumber: map['registrationNumber'] as String,
      address: map['address'] as String,
      countryCode: map['countryCode'] as String, // Add to fromMap
      imagePath: map['imagePath'] as String?,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  // Method to convert a Company object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'businessName': businessName,
      'yearsOfExperience': yearsOfExperience,
      'registrationNumber': registrationNumber,
      'address': address,
      'countryCode': countryCode, // Add to toMap
      'imagePath': imagePath,
      'imageUrl': imageUrl,
    };
  }


  Company copyWith({
    String? id,
    String? fullName,
    String? email,
    String? mobile,
    String? businessName,
    int? yearsOfExperience,
    String? registrationNumber,
    String? address,
    String? countryCode,
    String? imagePath,
    String? imageUrl,
  }) {
    return Company(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      businessName: businessName ?? this.businessName,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      address: address ?? this.address,
      countryCode: countryCode ?? this.countryCode,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
