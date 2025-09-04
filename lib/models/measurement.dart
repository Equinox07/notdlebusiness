import 'dart:convert';

import 'package:notdle/models/customer.dart';

class Measurement {
  final int? id; // 🔹 Auto-generated primary key
  final int customerId; // links to Customer.id
  final Map<String, double> measurementValues; // all measurement fields
  final DateTime createdDate;

   // 🔹 Linked customer object (not stored in DB)
  Customer? customer;

  Measurement({
    this.id,
    required this.customerId,
    required this.measurementValues,
    DateTime? createdDate,
    this.customer, // optional
  }) : createdDate = createdDate ?? DateTime.now();

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      id: map['id'] as int?,
      customerId: map['customerId'] as int,
      measurementValues: map['measurementValues'] != null
          ? Map<String, double>.from(jsonDecode(map['measurementValues']))
          : {},
      createdDate: DateTime.parse(map['createdDate']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'customerId': customerId,
      'measurementValues': jsonEncode(measurementValues),
      'createdDate': createdDate.toIso8601String(),
    };
    if (id != null) map['id'] = id!;
    return map;
  }

   // Optional: assign customer after fetching from DB
  void linkCustomer(Customer c) {
    customer = c;
  }
}

// class Measurement {
//   final int? id;
//   final int customerId;
//   final Map<String, double> values;
//   final DateTime createdDate; // 🔹 New

//   Measurement({
//     this.id,
//     required this.customerId,
//     required this.values,
//     required this.createdDate,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'customerId': customerId,
//       'values': values.map((k, v) => MapEntry(k, v.toString())),
//       'createdDate': createdDate.toIso8601String(), // 🔹 Save
//     };
//   }

//   factory Measurement.fromMap(Map<String, dynamic> map) {
//     final values = <String, double>{};
//     (map['values'] as Map<String, dynamic>).forEach((key, value) {
//       values[key] = double.tryParse(value.toString()) ?? 0.0;
//     });

//     return Measurement(
//       customerId: map['customerId'],
//       id: map['id'] as int?,
//       values: values,
//       createdDate: DateTime.parse(map['createdDate']), // 🔹 Load
      
//     );
    
//   }
// }
