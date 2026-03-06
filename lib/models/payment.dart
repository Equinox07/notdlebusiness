// lib/models/payment.dart
import 'package:floor/floor.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'invoice.dart'; // Assuming Invoice model is in invoice.dart

@Entity(
  tableName: 'payments',
  foreignKeys: [
    ForeignKey(
      childColumns: ['invoiceId'],
      parentColumns: ['id'],
      entity: Invoice,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class Payment {
  @PrimaryKey()
  final String id;
  final String invoiceId;
  final String? companyId; // companyId is now optional
  final double amount;
  final int amountCents; // New field: amount in cents
  final DateTime paymentDate;
  final String? referenceNumber;
  final String? notes;
  final String status;
  final DateTime? syncDate; // New field
  final bool isSynced; // New field
  final String? userId;
  final String method; // e.g., "Credit Card", "Cash", "Bank Transfer"
  bool isPaid;

  Payment({
    String? id,
    required this.invoiceId,
    this.companyId, // Make optional in constructor
    required this.amount,
    required this.amountCents, // Add to constructor
    required this.paymentDate,
    this.referenceNumber,
    this.notes,
    required this.status,
    this.syncDate, // Add to constructor
    this.isSynced = false, // Add to constructor with default value
    this.userId,
    required this.method, // Add to constructor
    this.isPaid = false, // Add to constructor with default value
  }) : id = id ?? const Uuid().v4();

  Payment copyWith({
    String? id,
    String? invoiceId,
    String? companyId, // Make optional in copyWith
    double? amount,
    int? amountCents, // Add to copyWith
    DateTime? paymentDate,
    String? referenceNumber,
    String? notes,
    String? status,
    DateTime? syncDate, // Add to copyWith
    bool? isSynced, // Add to copyWith
    String? userId,
    String? method, // Add to copyWith
    bool? isPaid, // Add to copyWith
  }) {
    return Payment(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      companyId: companyId ?? this.companyId, // Update in copyWith
      amount: amount ?? this.amount,
      amountCents: amountCents ?? this.amountCents, // Update in copyWith
      paymentDate: paymentDate ?? this.paymentDate,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      syncDate: syncDate ?? this.syncDate, // Update in copyWith
      isSynced: isSynced ?? this.isSynced, // Update in copyWith
      userId: userId ?? this.userId,
      method: method ?? this.method, // Update in copyWith
      isPaid: isPaid ?? this.isPaid, // Update in copyWith
    );
  }
}

extension PaymentExtension on Payment {
  /// Safe cents getter (fallback if cents not set)
  int get safeCents {
    if (amountCents > 0) return amountCents;
    return (amount * 100).round();
  }

  /// Convert cents to double amount
  double get amountFromCents {
    return safeCents / 100.0;
  }

  /// Format payment amount with currency
  String formatAmount({String locale = 'en_US', String currencyCode = 'USD'}) {
    final formatter = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
    );

    return formatter.format(amountFromCents);
  }

  /// Check if payment is completed
  bool get isCompleted {
    return status.toLowerCase() == 'completed' || isPaid;
  }

  /// Check if payment is pending
  bool get isPending {
    return status.toLowerCase() == 'pending';
  }

  /// Check if payment failed
  bool get isFailed {
    return status.toLowerCase() == 'failed';
  }

  /// Human readable method
  String get methodLabel {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'credit_card':
        return 'Credit Card';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return method;
    }
  }

  /// Short display summary
  String summary({String locale = 'en_US', String currencyCode = 'USD'}) {
    return "${formatAmount(locale: locale, currencyCode: currencyCode)} • $methodLabel";
  }
}
