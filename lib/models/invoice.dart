// lib/models/invoice.dart
import 'package:floor/floor.dart';
import 'package:notdle/models/invoice_item.dart';
import 'package:notdle/models/payment.dart'; // Import the Payment model
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
  final String customerId; // Foreign key to Customer
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

  @ignore
  final List<InvoiceItem> items;
  @ignore
  final List<Payment> payments; // Add payments list

  Invoice({
    required this.id,
    required this.customerId,
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
  });

  Invoice copyWith({
    String? customerId,
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
  }) {
    return Invoice(
      id: id,
      customerId: customerId ?? this.customerId,
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
    );
  }
}
