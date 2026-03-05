// lib/models/payment.dart
import 'package:floor/floor.dart';
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
  final DateTime paymentDate;
  final String? referenceNumber;
  final String? notes;
  final String status;
  final DateTime? syncDate; // New field
  final bool isSynced; // New field
  final String? userId;
  final String method; // e.g., "Credit Card", "Cash", "Bank Transfer"

  Payment({
    String? id,
    required this.invoiceId,
    this.companyId, // Make optional in constructor
    required this.amount,
    required this.paymentDate,
    this.referenceNumber,
    this.notes,
    required this.status,
    this.syncDate, // Add to constructor
    this.isSynced = false, // Add to constructor with default value
    this.userId,
    required this.method, // Add to constructor
  }) : id = id ?? const Uuid().v4();

  Payment copyWith({
    String? id,
    String? invoiceId,
    String? companyId, // Make optional in copyWith
    double? amount,
    DateTime? paymentDate,
    String? referenceNumber,
    String? notes,
    String? status,
    DateTime? syncDate, // Add to copyWith
    bool? isSynced, // Add to copyWith
    String? userId,
    String? method, // Add to copyWith
  }) {
    return Payment(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      companyId: companyId ?? this.companyId, // Update in copyWith
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      syncDate: syncDate ?? this.syncDate, // Update in copyWith
      isSynced: isSynced ?? this.isSynced, // Update in copyWith
      userId: userId ?? this.userId,
      method: method ?? this.method, // Update in copyWith
    );
  }
}
