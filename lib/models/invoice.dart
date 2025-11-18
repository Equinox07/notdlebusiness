// lib/models/invoice.dart
import 'package:floor/floor.dart';
import 'customer.dart';
import 'order.dart';

@Entity(
    tableName: 'invoices',
    foreignKeys: [
      ForeignKey(childColumns: ['customerId'], parentColumns: ['id'],
          entity: Customer,
      onDelete: ForeignKeyAction.cascade),
      ForeignKey(childColumns: ['orderId'], parentColumns: ['id'], entity: Order,
          onDelete: ForeignKeyAction.setNull)
    ]
)
class Invoice {
  @PrimaryKey()
  final String id;
  final String title;
  final String customerId; // Foreign key to Customer
  final String status;
  final double totalAmount;
  final DateTime date; // Requires DateTimeConverter
  final String orderId; // Foreign key to Order
  final String? createdDate;
  final String? updatedDate;

  Invoice({
    required this.id,
    required this.title,
    required this.customerId,
    required this.status,
    required this.totalAmount,
    required this.date,
    required this.orderId,
    this.createdDate,
    this.updatedDate,
  });

  Invoice copyWith({
    String? title,
    String? customerId,
    String? status,
    double? totalAmount,
    DateTime? date,
    String? orderId,
    String? createdDate,
    String? updatedDate,
  }) {
    return Invoice(
      id: id,
      title: title ?? this.title,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      date: date ?? this.date,
      orderId: orderId ?? this.orderId,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }


  // // Convert an Invoice object into a Map.
  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'title': title,
  //     'customerId': customerId,
  //     'status': status,
  //     'totalAmount': totalAmount,
  //     'date': date.toIso8601String(), // Store date as a string
  //     'orderId': orderId
  //     // 'createdDate': createdDate
  //   };
  // }
  //
  // // Create an Invoice object from a Map.
  // factory Invoice.fromMap(Map<String, dynamic> map) {
  //   return Invoice(
  //     id: map['id'],
  //     title: map['title'],
  //     customerId: map['customerId'] as int,
  //     status: map['status'],
  //     totalAmount: map['totalAmount'],
  //     date: DateTime.parse(map['date']),
  //     orderId: map['orderId']
  //       // createdDate: map['createdDate'] as String
  //   );
  // }
}
