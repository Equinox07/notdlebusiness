import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';
import 'customer.dart';

@Entity(
  tableName: 'measurements',
  foreignKeys: [
    ForeignKey(
      childColumns: ['customerId'],
      parentColumns: ['id'],
      entity: Customer,
    ),
  ],
)
class Measurement {
  @PrimaryKey()
  final String id;

  final String customerId;
  final String name; // New name field

  /// Stored via TypeConverter as JSON string
  final Map<String, double> measurementValues;

  /// Stored via TypeConverter as ISO string
  final DateTime createdDate;

  final DateTime? updatedDate;
  final DateTime? syncDate; // New field
  final bool isSynced; // New field
  final String? companyId;
  final String? userId;

  @ignore
  Customer? customer;

  Measurement({
    String? id,
    required this.customerId,
    required this.name, // Add name to constructor
    required this.measurementValues,
    required this.createdDate,
    this.updatedDate,
    this.customer,
    this.syncDate, // Add to constructor
    this.isSynced = false, // Add to constructor with default value
    this.companyId,
    this.userId,
  }) : id = id ?? const Uuid().v4();

  void linkCustomer(Customer c) {
    customer = c;
  }

  Measurement copyWith({
    String? id,
    String? customerId,
    String? name, // Add name to copyWith
    Map<String, double>? measurementValues,
    DateTime? createdDate,
    DateTime? updatedDate,
    DateTime? syncDate, // Add to copyWith
    bool? isSynced, // Add to copyWith
    String? companyId,
    String? userId,
  }) {
    return Measurement(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name, // Update name in copyWith
      measurementValues: measurementValues ?? this.measurementValues,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      customer: customer,
      syncDate: syncDate ?? this.syncDate, // Update in copyWith
      isSynced: isSynced ?? this.isSynced, // Update in copyWith
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
    );
  }
}
