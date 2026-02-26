import 'package:json_annotation/json_annotation.dart';

part 'invoice_model.g.dart';

@JsonSerializable()
class InvoiceDto {
  final String? id;
  final String? externalId;
  final String invoiceNumber;
  final DateTime issueDate;
  final DateTime dueDate;
  final String? notes;
  final String? terms;
  final double subtotal;
  final double tax;
  final double total;
  final String status;
  final String projectId;
  final List<InvoiceItemDto> items;
  final List<PaymentDto> payments;
  final String? companyId;
  final String? userId;

  InvoiceDto({
    this.id,
    this.externalId,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    this.notes,
    this.terms,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.projectId,
    required this.items,
    required this.payments,
    this.companyId,
    this.userId,
  });

  factory InvoiceDto.fromJson(Map<String, dynamic> json) =>
      _$InvoiceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceDtoToJson(this);
}

@JsonSerializable()
class InvoiceItemDto {
  final String? id;
  final String? externalId;
  final String description;
  final int quantity;
  final double unitPrice;
  final double? taxRate;
  final double amount;
  final String? invoiceId;
  final String? companyId;
  final String? userId;

  InvoiceItemDto({
    this.id,
    this.externalId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxRate,
    required this.amount,
    this.invoiceId,
    this.companyId,
    this.userId,
  });

  factory InvoiceItemDto.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceItemDtoToJson(this);
}

@JsonSerializable()
class PaymentDto {
  final String? id;
  final String? externalId;
  final double amount;
  final DateTime paymentDate;
  final String? referenceNumber;
  final String? notes;
  final String status;
  final String invoiceId;
  final String companyId;
  final String? userId;

  PaymentDto({
    this.id,
    this.externalId,
    required this.amount,
    required this.paymentDate,
    this.referenceNumber,
    this.notes,
    required this.status,
    required this.invoiceId,
    required this.companyId,
    this.userId,
  });

  factory PaymentDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentDtoToJson(this);
}
