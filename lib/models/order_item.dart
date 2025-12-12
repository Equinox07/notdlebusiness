// lib/models/order_item.dart
import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';
import 'order.dart'; // Assuming Order model is in order.dart

@Entity(
  tableName: 'order_items',
  foreignKeys: [
    ForeignKey(
      childColumns: ['orderId'],
      parentColumns: ['id'],
      entity: Order,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
)
class OrderItem {
  @PrimaryKey()
  final String id;
  final String orderId;
  final String productName;
  final String? productDescription;
  final int quantity;
  final double unitPrice;
  final double? taxRate;
  final double amount;

  OrderItem({
    String? id,
    required this.orderId,
    required this.productName,
    this.productDescription,
    required this.quantity,
    required this.unitPrice,
    this.taxRate,
    required this.amount,
  }) : id = id ?? const Uuid().v4();

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? productName,
    String? productDescription,
    int? quantity,
    double? unitPrice,
    double? taxRate,
    double? amount,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      amount: amount ?? this.amount,
    );
  }
}
