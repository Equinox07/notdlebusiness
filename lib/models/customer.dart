// lib/models/customer.dart

import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';

@Entity(tableName: 'customers')
class Customer {
  @PrimaryKey()
  final String? id;
  final String name;
  final String phone;
  final String? email;
  final String? instagram; // New field
  final DateTime lastVisit;
  final String gender;
  final String? address;
  String? imagePath;
  String? profileImageUrl;
  final String?
  stylePreferences; // New field (stored as comma-separated or JSON)
  final String? favoriteFabrics; // New field
  final String? notes; // New field
  final DateTime createdDate;
  final DateTime? syncDate;
  final bool isSynced;
  final String? companyId;
  final String? userId;

  Customer({
    String? id,
    required this.name,
    required this.phone,
    this.email,
    this.instagram,
    required this.lastVisit,
    required this.gender,
    this.address,
    this.imagePath,
    this.profileImageUrl,
    this.stylePreferences,
    this.favoriteFabrics,
    this.notes,
    required this.createdDate,
    this.syncDate,
    this.isSynced = false,
    this.companyId,
    this.userId,
  }) : id = id ?? const Uuid().v4();

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? instagram,
    DateTime? lastVisit,
    String? gender,
    String? address,
    String? imagePath,
    String? profileImageUrl,
    String? stylePreferences,
    String? favoriteFabrics,
    String? notes,
    DateTime? createdDate,
    DateTime? syncDate,
    bool? isSynced,
    String? companyId,
    String? userId,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      instagram: instagram ?? this.instagram,
      lastVisit: lastVisit ?? this.lastVisit,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      imagePath: imagePath ?? this.imagePath,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      stylePreferences: stylePreferences ?? this.stylePreferences,
      favoriteFabrics: favoriteFabrics ?? this.favoriteFabrics,
      notes: notes ?? this.notes,
      createdDate: createdDate ?? this.createdDate,
      syncDate: syncDate ?? this.syncDate,
      isSynced: isSynced ?? this.isSynced,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
    );
  }
}
