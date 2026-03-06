// lib/models/order.dart
import 'package:floor/floor.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/order_item.dart'; // Import the OrderItem model
import 'package:uuid/uuid.dart';
import 'customer.dart';

enum ProductionStage { measure, cutting, sewing, fitting, ready }

@Entity(
  tableName: 'orders',
  foreignKeys: [
    ForeignKey(
      childColumns: ['customerId'],
      parentColumns: ['id'],
      entity: Customer,
    ),
  ],
)
class Order {
  @PrimaryKey()
  final String id;
  final String title;
  final String customerId; // Foreign key
  final String status;
  final String paymentStatus;
  final double? paymentAmount;
  final String? dueDate;
  final String? notes;
  final String createdDate; // New field
  final String? orderNumber;
  final double? subtotal;
  final double? total;
  final double? tax;
  final DateTime? expectedDeliveryDate;
  final DateTime? syncDate; // New field
  final bool isSynced; // New field
  final String? companyId;
  final String? userId;
  final ProductionStage currentStage; // New field for production stage
  final List<String> designReferences;
  final double totalQuotation;
  final double paidAmount;
  final String garmentType;
  final String fabric;
  final String lining;

  @ignore
  final List<OrderItem> items; // Add items list

  Order({
    required this.title,
    required this.customerId,
    required this.status,
    required this.paymentStatus,
    this.paymentAmount,
    this.dueDate,
    this.notes,
    required this.createdDate, // Add to constructor
    String? id,
    this.orderNumber,
    this.subtotal,
    this.total,
    this.tax,
    this.expectedDeliveryDate,
    this.items = const [], // Initialize items list
    this.syncDate, // Add to constructor
    this.isSynced = false, // Add to constructor with default value
    this.companyId,
    this.userId,
    this.currentStage = ProductionStage.measure, // Initialize production stage
    this.designReferences = const [], // Initialize design references
    this.totalQuotation = 0, // Initialize total quotation
    this.paidAmount = 0, // Initialize paid amount
    this.garmentType = '', // Add garment type
    this.fabric = '', // Add fabric
    this.lining = '', // Add lining
  }) : id = id ?? const Uuid().v4();

  Order copyWith({
    String? title,
    String? customerId,
    String? status,
    String? paymentStatus,
    double? paymentAmount,
    String? dueDate,
    String? notes,
    String? createdDate,
    String? orderNumber,
    double? subtotal,
    double? total,
    double? tax,
    DateTime? expectedDeliveryDate,
    List<OrderItem>? items, // Add items to copyWith
    DateTime? syncDate, // Add to copyWith
    bool? isSynced, // Add to copyWith
    String? companyId,
    String? userId,
    ProductionStage? currentStage, // Add currentStage to copyWith
    List<String>? designReferences, // Add designReferences to copyWith
    double? totalQuotation, // Add totalQuotation to copyWith
    double? paidAmount, // Add paidAmount to copyWith
    String? garmentType, // Add garmentType to copyWith
    String? fabric, // Add fabric to copyWith
    String? lining, // Add lining to copyWith
  }) {
    return Order(
      id: id,
      title: title ?? this.title,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      createdDate: createdDate ?? this.createdDate,
      orderNumber: orderNumber ?? this.orderNumber,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      tax: tax ?? this.tax,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      items: items ?? this.items, // Update items in copyWith
      syncDate: syncDate ?? this.syncDate, // Update in copyWith
      isSynced: isSynced ?? this.isSynced, // Update in copyWith
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      currentStage:
          currentStage ?? this.currentStage, // Update currentStage in copyWith
      designReferences:
          designReferences ??
          this.designReferences, // Update designReferences in copyWith
      totalQuotation:
          totalQuotation ??
          this.totalQuotation, // Update totalQuotation in copyWith
      paidAmount:
          paidAmount ?? this.paidAmount, // Update paidAmount in copyWith
      garmentType:
          garmentType ?? this.garmentType, // Update garmentType in copyWith
      fabric: fabric ?? this.fabric, // Update fabric in copyWith
      lining: lining ?? this.lining, // Update lining in copyWith
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'customerId': customerId,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentAmount': paymentAmount,
      'dueDate': dueDate,
      'notes': notes,
      'createdDate': createdDate,
      'orderNumber': orderNumber,
      'subtotal': subtotal,
      'total': total,
      'tax': tax,
      'expectedDeliveryDate':
          expectedDeliveryDate?.toIso8601String(), // Convert to ISO string
      'syncDate': syncDate?.toIso8601String(), // Convert to ISO string
      'isSynced': isSynced,
      'companyId': companyId,
      'userId': userId,
      'currentStage':
          currentStage.toString().split('.').last, // Store enum as string
      'designReferences': designReferences, // Store list of design references
      'totalQuotation': totalQuotation, // Store total quotation
      'paidAmount': paidAmount, // Store paid amount
      'garmentType': garmentType, // Store garment type
      'fabric': fabric, // Store fabric
      'lining': lining, // Store lining
    };
  }

  // Calculate days remaining
  int get daysLeft =>
      DateTime.parse(dueDate!).difference(DateTime.now()).inDays;

  // Calculate balance
  double get balance => totalQuotation - paidAmount;

  //
  // // Convert an Order object into a Map.
  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'title': title,
  //     'customerId': customerId,
  //     'status': status,
  //     'paymentStatus': paymentStatus,
  //     'paymentAmount': paymentAmount,
  //     'dueDate': dueDate,
  //     'notes': notes,
  //     'invoiceId': invoiceId,
  //     'createdDate': createdDate,
  //   };
  // }
  //
  // // Create an Order object from a Map.
  // factory Order.fromMap(Map<String, dynamic> map) {
  //   return Order(
  //     id: map['id'],
  //     title: map['title'],
  //     customerId: map['customerId'] as int,
  //     status: map['status'],
  //     paymentStatus: map['paymentStatus'],
  //     paymentAmount: map['paymentAmount'],
  //     dueDate: map['dueDate'],
  //     notes: map['notes'],
  //     invoiceId: map['invoiceId'],
  //     createdDate: map['createdDate'] as String,
  //   );
  // }
}

extension OrderExtension on Order {
  // ---------- Dates ----------
  DateTime? get createdAt {
    try {
      return DateTime.parse(createdDate);
    } catch (_) {
      return null;
    }
  }

  DateTime? get dueAt {
    if (dueDate == null) return null;
    try {
      return DateTime.parse(dueDate!);
    } catch (_) {
      return null;
    }
  }

  // ---------- Payment ----------
  bool get isPaid => paymentStatus.toLowerCase() == "paid";

  bool get isPartiallyPaid => paymentStatus.toLowerCase() == "partial";

  double get balanceAmount {
    final totalAmount = total ?? 0;
    final paid = paymentAmount ?? 0;
    return totalAmount - paid;
  }

  // ---------- Currency ----------
  String totalFormatted({String symbol = "₵"}) {
    final formatter = NumberFormat.currency(symbol: symbol);
    return formatter.format(total ?? 0);
  }

  String balanceFormatted({String symbol = "₵"}) {
    final formatter = NumberFormat.currency(symbol: symbol);
    return formatter.format(balanceAmount);
  }

  String subtotalFormatted({String symbol = "₵"}) {
    final formatter = NumberFormat.currency(symbol: symbol);
    return formatter.format(subtotal ?? 0);
  }
}
