// lib/models/customer.dart

import 'package:floor/floor.dart';

@Entity(tableName: 'customers')
class Customer {
  @PrimaryKey()
  final String? id;
  final String name;
  final String phone;
  final String? email;
  final DateTime lastVisit;
  final String gender;
  final String? address;
  String? imagePath;
  String? profileImageUrl;
  final DateTime createdDate;
  final DateTime? syncDate; // New field
  final bool isSynced; // New field

  Customer({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.lastVisit,
    required this.gender,
    this.address,
    this.imagePath,
    this.profileImageUrl,
    required this.createdDate,
    this.syncDate, // Add to constructor
    this.isSynced = false, // Add to constructor with default value
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    DateTime? lastVisit,
    String? gender,
    String? address,
    String? imagePath,
    String? profileImageUrl,
    DateTime? createdDate,
    DateTime? syncDate, // Add to copyWith
    bool? isSynced, // Add to copyWith
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      lastVisit: lastVisit ?? this.lastVisit,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      imagePath: imagePath ?? this.imagePath,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdDate: createdDate ?? this.createdDate,
      syncDate: syncDate ?? this.syncDate, // Update in copyWith
      isSynced: isSynced ?? this.isSynced, // Update in copyWith
    );
  }
}
