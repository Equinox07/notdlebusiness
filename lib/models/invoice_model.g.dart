// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceDto _$InvoiceDtoFromJson(Map<String, dynamic> json) => InvoiceDto(
      id: json['id'] as String?,
      externalId: json['externalId'] as String?,
      invoiceNumber: json['invoiceNumber'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      notes: json['notes'] as String?,
      terms: json['terms'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      projectId: json['projectId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => InvoiceItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      payments: (json['payments'] as List<dynamic>)
          .map((e) => PaymentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      companyId: json['companyId'] as String?,
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$InvoiceDtoToJson(InvoiceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'externalId': instance.externalId,
      'invoiceNumber': instance.invoiceNumber,
      'issueDate': instance.issueDate.toIso8601String(),
      'dueDate': instance.dueDate.toIso8601String(),
      'notes': instance.notes,
      'terms': instance.terms,
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'total': instance.total,
      'status': instance.status,
      'projectId': instance.projectId,
      'items': instance.items,
      'payments': instance.payments,
      'companyId': instance.companyId,
      'userId': instance.userId,
    };

InvoiceItemDto _$InvoiceItemDtoFromJson(Map<String, dynamic> json) =>
    InvoiceItemDto(
      id: json['id'] as String?,
      externalId: json['externalId'] as String?,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      taxRate: (json['taxRate'] as num?)?.toDouble(),
      amount: (json['amount'] as num).toDouble(),
      invoiceId: json['invoiceId'] as String?,
      companyId: json['companyId'] as String?,
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$InvoiceItemDtoToJson(InvoiceItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'externalId': instance.externalId,
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'taxRate': instance.taxRate,
      'amount': instance.amount,
      'invoiceId': instance.invoiceId,
      'companyId': instance.companyId,
      'userId': instance.userId,
    };

PaymentDto _$PaymentDtoFromJson(Map<String, dynamic> json) => PaymentDto(
      id: json['id'] as String?,
      externalId: json['externalId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      referenceNumber: json['referenceNumber'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      invoiceId: json['invoiceId'] as String,
      companyId: json['companyId'] as String,
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$PaymentDtoToJson(PaymentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'externalId': instance.externalId,
      'amount': instance.amount,
      'paymentDate': instance.paymentDate.toIso8601String(),
      'referenceNumber': instance.referenceNumber,
      'notes': instance.notes,
      'status': instance.status,
      'invoiceId': instance.invoiceId,
      'companyId': instance.companyId,
      'userId': instance.userId,
    };
