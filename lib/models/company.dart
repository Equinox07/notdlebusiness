// lib/models/company.dart

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Company {
  final String id;
  final String fullName;
  final String email;
  final String mobile;
  final String businessName;
  final int yearsOfExperience;
  final String registrationNumber;
  final String address;
  final String countryCode; // New field for the country code

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
    };
  }
}
