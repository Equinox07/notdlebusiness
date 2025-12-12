// lib/models/invoice_item.dart
import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';
import 'invoice.dart';

@Entity(
  tableName: 'invoice_items',
  foreignKeys: [
    ForeignKey(
      childColumns: ['invoiceId'],
      parentColumns: ['id'],
      entity: Invoice,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
)
class InvoiceItem {
  @PrimaryKey()
  final String id;
  final String invoiceId;
  final String description;
  final int quantity;
  final double unitPrice;
  final double? taxRate;
  final double amount;
  final DateTime? syncDate; // New field
  final bool isSynced; // New field

  InvoiceItem({
    String? id,
    required this.invoiceId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxRate,
    required this.amount,
    this.syncDate, // Add to constructor
    this.isSynced = false, // Add to constructor with default value
  }) : id = id ?? const Uuid().v4();

  InvoiceItem copyWith({
    String? id,
    String? invoiceId,
    String? description,
    int? quantity,
    double? unitPrice,
    double? taxRate,
    double? amount,
    DateTime? syncDate, // Add to copyWith
    bool? isSynced, // Add to copyWith
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      amount: amount ?? this.amount,
      syncDate: syncDate ?? this.syncDate, // Update in copyWith
      isSynced: isSynced ?? this.isSynced, // Update in copyWith
    );
  }
}
