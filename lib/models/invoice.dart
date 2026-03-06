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
  final int? subtotalCents; // New field: subtotal in cents
  final double? tax;
  final double total;
  final int? taxCents; // New field: tax in cents
  final int?
  taxRate; // New field: tax rate in basis points (e.g., 750 for 7.5%)
  final int totalCents; // New field: total in cents
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
    required this.total,
    this.projectId,
    this.items = const [],
    this.payments = const [], // Initialize payments list
    this.syncDate, // Add to constructor
    this.isSynced = false, // Add to constructor with default value
    this.title, // Add to constructor
    this.date, // Add to constructor
    this.orderId, // Add to constructor
    this.isPaid = false, // Initialize isPaid
    this.subtotalCents, // Add to constructor
    this.taxCents, // Add to constructor
    this.taxRate, // Add to constructor
    required this.totalCents, // Add to constructor
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
    int? subtotalCent, // Add to copyWith
    int? taxCent, // Add to copyWith
    int? taxRate, // Add to copyWith
    int? totalCents, // Add to copyWith
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
      subtotalCents: subtotalCents ?? this.subtotalCents, // Update in copyWith
      taxCents: taxCents ?? this.taxCents, // Update in copyWith
      taxRate: taxRate ?? this.taxRate, // Update in copyWith
      totalCents: totalCents ?? this.totalCents, // Update in copyWith
    );
  }
}

extension InvoicePaymentExtension on Invoice {
  /// Sum of all payments linked to this invoice
  double get paymentSum {
    if (payments.isEmpty) return 0.0;
    return payments.fold(0.0, (sum, payment) => sum + (payment.amount ?? 0));
  }

  /// Remaining balance on the invoice
  double get remainBalance {
    final invoiceTotal = total ?? 0.0;
    return invoiceTotal - paymentSum;
  }

  /// Check if invoice is fully paid
  bool get isFullyPaid {
    return remainBalance <= 0;
  }

  /// Check if partially paid
  // bool get isPartiallyPaid {
  //   return paymentSum > 0 && remainBalance > 0;
  // }

  int get paymentTotalCents {
    if (payments.isEmpty) return 0;

    return payments.fold(0, (sum, p) => sum + p.amountCents);
  }

  int get invoiceTotalCents {
    return totalCents ?? 0;
  }

  int get remainingBalanceCents {
    final remain = invoiceTotalCents - paymentTotalCents;
    return remain < 0 ? 0 : remain;
  }

  bool get isPaid {
    return remainingBalanceCents == 0 && paymentTotalCents > 0;
  }

  bool get isPartiallyPaid {
    return paymentTotalCents > 0 && remainingBalanceCents > 0;
  }
}
