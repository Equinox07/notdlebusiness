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

  InvoiceItem({
    String? id,
    required this.invoiceId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxRate,
    required this.amount,
  }) : id = id ?? const Uuid().v4();

  InvoiceItem copyWith({
    String? id,
    String? invoiceId,
    String? description,
    int? quantity,
    double? unitPrice,
    double? taxRate,
    double? amount,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      amount: amount ?? this.amount,
    );
  }
}
