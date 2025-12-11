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
  });

  // Convert a Customer object into a Map for database storage.
  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'name': name,
  //     'phone': phone,
  //     'email': email,
  //     'lastVisit': lastVisit.toIso8601String(),
  //     'gender': gender,
  //     'address': address,
  //     'imagePath': imagePath,
  //     'profileImageUrl': profileImageUrl,
  //     'createdDate': createdDate.toIso8601String(),
  //   };
  // }
  //
  // // Create a Customer object from a Map from the database.
  // factory Customer.fromMap(Map<String, dynamic> map) {
  //   return Customer(
  //     id: map['id'],
  //     name: map['name'],
  //     phone: map['phone'],
  //     email: map['email'],
  //     lastVisit: DateTime.parse(map['lastVisit']),
  //     gender: map['gender'],
  //     address: map['address'],
  //     imagePath: map['imagePath'],
  //     profileImageUrl: map['profileImageUrl'],
  //     createdDate: DateTime.parse(map['createdDate']),
  //   );
  // }

  // Method to fetch the count of all orders for this customer from the database.
  // Future<int> getTotalOrders() async {
  //   final dbHelper = DatabaseHelper.instance;
  //   final Database db = await dbHelper.database;
  //   final count = Sqflite.firstIntValue(
  //     await db.rawQuery('SELECT COUNT(*) FROM orders WHERE customerId = ?', [
  //       id,
  //     ]),
  //   );
  //   return count ?? 0;
  // }
}
