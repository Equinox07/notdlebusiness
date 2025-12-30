// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDto _$OrderDtoFromJson(Map<String, dynamic> json) => OrderDto(
      id: json['id'] as String?,
      externalId: json['externalId'] as String?,
      orderNumber: json['orderNumber'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
      expectedDeliveryDate:
          DateTime.parse(json['expectedDeliveryDate'] as String),
      notes: json['notes'] as String?,
      status: json['status'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      companyId: json['companyId'] as String,
      clientId: json['clientId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderDtoToJson(OrderDto instance) => <String, dynamic>{
      'id': instance.id,
      'externalId': instance.externalId,
      'orderNumber': instance.orderNumber,
      'orderDate': instance.orderDate.toIso8601String(),
      'expectedDeliveryDate': instance.expectedDeliveryDate.toIso8601String(),
      'notes': instance.notes,
      'status': instance.status,
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'total': instance.total,
      'companyId': instance.companyId,
      'clientId': instance.clientId,
      'items': instance.items,
    };

OrderItemDto _$OrderItemDtoFromJson(Map<String, dynamic> json) => OrderItemDto(
      id: json['id'] as String?,
      externalId: json['externalId'] as String?,
      productName: json['productName'] as String,
      productDescription: json['productDescription'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      taxRate: (json['taxRate'] as num?)?.toDouble(),
      amount: (json['amount'] as num).toDouble(),
      orderId: json['orderId'] as String?,
    );

Map<String, dynamic> _$OrderItemDtoToJson(OrderItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'externalId': instance.externalId,
      'productName': instance.productName,
      'productDescription': instance.productDescription,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'taxRate': instance.taxRate,
      'amount': instance.amount,
      'orderId': instance.orderId,
    };
