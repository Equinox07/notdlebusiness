// lib/models/invoice.dart
import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';

import 'package:notdle/models/invoice_item.dart';
import 'package:notdle/models/payment.dart'; // Import the Payment model
import 'customer.dart';
import 'order.dart';

@Entity(
  tableName: 'invoices',
  foreignKeys: [
    ForeignKey(
      childColumns: ['customerId'],
      parentColumns: ['id'],
      entity: Customer,
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['orderId'],
      parentColumns: ['id'],
      entity: Order,
      onDelete: ForeignKeyAction.setNull,
    ),
  ],
)
class Invoice {
  @PrimaryKey()
  final String id;
  final String customerId; // Foreign key to Customer
  final String? companyId; // New field: companyId - now optional
  final String? userId;
  final String status;
  final String? createdDate;
  final String? updatedDate;
  final String? invoiceNumber;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final String? notes;
  final String? terms;
  final double? subtotal;
  final double? tax;
  final double? total;
  final String? projectId;
  final DateTime? syncDate; // New field
  final bool isSynced; // New field
  final String? title; // New field
  final DateTime? date; // New field
  final String? orderId; // New field
  bool isPaid;

  @ignore
  final List<InvoiceItem> items;
  @ignore
  final List<Payment> payments; // Add payments list

  Invoice({
    String? id,
    required this.customerId,
    this.companyId, // Make optional in constructor
    this.userId,
    required this.status,
    this.createdDate,
    this.updatedDate,
    this.invoiceNumber,
    this.issueDate,
    this.dueDate,
    this.notes,
    this.terms,
    this.subtotal,
    this.tax,
    this.total,
    this.projectId,
    this.items = const [],
    this.payments = const [], // Initialize payments list
    this.syncDate, // Add to constructor
    this.isSynced = false, // Add to constructor with default value
    this.title, // Add to constructor
    this.date, // Add to constructor
    this.orderId, // Add to constructor
    this.isPaid = false, // Initialize isPaid
  }) : id = id ?? const Uuid().v4();

  Invoice copyWith({
    String? customerId,
    String? companyId, // Make optional in copyWith
    String? userId,
    String? status,
    String? createdDate,
    String? updatedDate,
    String? invoiceNumber,
    DateTime? issueDate,
    DateTime? dueDate,
    String? notes,
    String? terms,
    double? subtotal,
    double? tax,
    double? total,
    String? projectId,
    List<InvoiceItem>? items,
    List<Payment>? payments, // Add payments to copyWith
    DateTime? syncDate, // Add to copyWith
    bool? isSynced, // Add to copyWith
    String? title, // Add to copyWith
    DateTime? date, // Add to copyWith
    String? orderId, // Add to copyWith
    bool? isPaid, // Add isPaid to copyWith
  }) {
    return Invoice(
      id: id,
      customerId: customerId ?? this.customerId,
      companyId: companyId ?? this.companyId, // Update in copyWith
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      projectId: projectId ?? this.projectId,
      items: items ?? this.items,
      payments: payments ?? this.payments, // Update payments in copyWith
      syncDate: syncDate ?? this.syncDate, // Update in copyWith
      isSynced: isSynced ?? this.isSynced, // Update in copyWith
      title: title ?? this.title, // Update in copyWith
      date: date ?? this.date, // Update in copyWith
      orderId: orderId ?? this.orderId, // Update in copyWith
      isPaid: isPaid ?? this.isPaid, // Update isPaid in copyWith
    );
  }
}
