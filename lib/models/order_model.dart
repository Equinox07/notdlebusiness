import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderDto {
  final String? id;
  final String orderNumber;
  final DateTime orderDate;
  final DateTime expectedDeliveryDate;
  final String? notes;
  final String status;
  final double subtotal;
  final double tax;
  final double total;
  final String companyId;
  final String clientId;
  final List<OrderItemDto> items;

  OrderDto({
    this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.expectedDeliveryDate,
    this.notes,
    required this.status,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.companyId,
    required this.clientId,
    required this.items,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) => _$OrderDtoFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDtoToJson(this);
}

@JsonSerializable()
class OrderItemDto {
  final String? id;
  final String productName;
  final String? productDescription;
  final int quantity;
  final double unitPrice;
  final double? taxRate;
  final double amount;
  final String? orderId;

  OrderItemDto({
    this.id,
    required this.productName,
    this.productDescription,
    required this.quantity,
    required this.unitPrice,
    this.taxRate,
    required this.amount,
    this.orderId,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) => _$OrderItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemDtoToJson(this);
}
