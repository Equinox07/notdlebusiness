import 'dart:convert';

class Measurement {
  final int? id; // 🔹 Auto-generated primary key
  final int customerId; // links to Customer.id
  final Map<String, double> values; // all measurement fields
  final DateTime createdDate;

  Measurement({
    this.id,
    required this.customerId,
    required this.values,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      id: map['id'] as int?,
      customerId: map['customerId'] as int,
      values: map['values'] != null
          ? Map<String, double>.from(jsonDecode(map['values']))
          : {},
      createdDate: DateTime.parse(map['createdDate']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'customerId': customerId,
      'values': jsonEncode(values),
      'createdDate': createdDate.toIso8601String(),
    };
    if (id != null) map['id'] = id!;
    return map;
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
