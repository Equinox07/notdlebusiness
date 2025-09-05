// lib/models/customer.dart

import 'package:notdle/db/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final DateTime lastVisit;
  final String gender;
  final String? address;
  String? imagePath;
  String? imageUrl;
  final DateTime createdDate;

  Customer({
    String? id,
    required this.name,
    required this.phone,
    this.email,
    required this.lastVisit,
    required this.gender,
    this.address,
    this.imagePath,
    this.imageUrl,
    required this.createdDate,
  }) : id = id ?? const Uuid().v4();

  // Convert a Customer object into a Map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'lastVisit': lastVisit.toIso8601String(),
      'gender': gender,
      'address': address,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  // Create a Customer object from a Map from the database.
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      lastVisit: DateTime.parse(map['lastVisit']),
      gender: map['gender'],
      address: map['address'],
      imagePath: map['imagePath'],
      imageUrl: map['imageUrl'],
      createdDate: DateTime.parse(map['createdDate']),
    );
  }

  // Method to fetch the count of all orders for this customer from the database.
  Future<int> getTotalOrders() async {
    final dbHelper = DatabaseHelper.instance;
    final Database db = await dbHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM orders WHERE customerId = ?', [
        id,
      ]),
    );
    return count ?? 0;
  }
}
