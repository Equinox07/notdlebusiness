// lib/models/order.dart
import 'package:floor/floor.dart';
import 'package:notdle/models/order_item.dart'; // Import the OrderItem model
import 'package:uuid/uuid.dart';
import 'customer.dart';

@Entity(
  tableName: 'orders',
  foreignKeys: [
    ForeignKey(
      childColumns: ['customerId'],
      parentColumns: ['id'],
      entity: Customer,
    ),
  ],
)
class Order {
  @PrimaryKey()
  final String id;
  final String title;
  final String customerId; // Foreign key
  final String status;
  final String paymentStatus;
  final double? paymentAmount;
  final String? dueDate;
  final String? notes;
  final String createdDate; // New field
  final String? orderNumber;
  final double? subtotal;
  final double? total;
  final double? tax;
  final DateTime? expectedDeliveryDate;
  final DateTime? syncDate; // New field
  final bool isSynced; // New field
  final String? companyId;
  final String? userId;

  @ignore
  final List<OrderItem> items; // Add items list

  Order({
    required this.title,
    required this.customerId,
    required this.status,
    required this.paymentStatus,
    this.paymentAmount,
    this.dueDate,
    this.notes,
    required this.createdDate, // Add to constructor
    String? id,
    this.orderNumber,
    this.subtotal,
    this.total,
    this.tax,
    this.expectedDeliveryDate,
    this.items = const [], // Initialize items list
    this.syncDate, // Add to constructor
    this.isSynced = false, // Add to constructor with default value
    this.companyId,
    this.userId,
  }) : id = id ?? const Uuid().v4();

  Order copyWith({
    String? title,
    String? customerId,
    String? status,
    String? paymentStatus,
    double? paymentAmount,
    String? dueDate,
    String? notes,
    String? createdDate,
    String? orderNumber,
    double? subtotal,
    double? total,
    double? tax,
    DateTime? expectedDeliveryDate,
    List<OrderItem>? items, // Add items to copyWith
    DateTime? syncDate, // Add to copyWith
    bool? isSynced, // Add to copyWith
    String? companyId,
    String? userId,
  }) {
    return Order(
      id: id,
      title: title ?? this.title,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      createdDate: createdDate ?? this.createdDate,
      orderNumber: orderNumber ?? this.orderNumber,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      tax: tax ?? this.tax,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      items: items ?? this.items, // Update items in copyWith
      syncDate: syncDate ?? this.syncDate, // Update in copyWith
      isSynced: isSynced ?? this.isSynced, // Update in copyWith
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
    );
  }

  //
  // // Convert an Order object into a Map.
  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'title': title,
  //     'customerId': customerId,
  //     'status': status,
  //     'paymentStatus': paymentStatus,
  //     'paymentAmount': paymentAmount,
  //     'dueDate': dueDate,
  //     'notes': notes,
  //     'invoiceId': invoiceId,
  //     'createdDate': createdDate,
  //   };
  // }
  //
  // // Create an Order object from a Map.
  // factory Order.fromMap(Map<String, dynamic> map) {
  //   return Order(
  //     id: map['id'],
  //     title: map['title'],
  //     customerId: map['customerId'] as int,
  //     status: map['status'],
  //     paymentStatus: map['paymentStatus'],
  //     paymentAmount: map['paymentAmount'],
  //     dueDate: map['dueDate'],
  //     notes: map['notes'],
  //     invoiceId: map['invoiceId'],
  //     createdDate: map['createdDate'] as String,
  //   );
  // }
}
