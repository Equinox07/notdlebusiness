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
    )
  ],
)
class Payment {
  @PrimaryKey()
  final String id;
  final String invoiceId;
  final String companyId; // Assuming companyId is stored with the payment
  final double amount;
  final DateTime paymentDate;
  final String? referenceNumber;
  final String? notes;
  final String status;

  Payment({
    String? id,
    required this.invoiceId,
    required this.companyId,
    required this.amount,
    required this.paymentDate,
    this.referenceNumber,
    this.notes,
    required this.status,
  }) : id = id ?? const Uuid().v4();

  Payment copyWith({
    String? id,
    String? invoiceId,
    String? companyId,
    double? amount,
    DateTime? paymentDate,
    String? referenceNumber,
    String? notes,
    String? status,
  }) {
    return Payment(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      companyId: companyId ?? this.companyId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}
