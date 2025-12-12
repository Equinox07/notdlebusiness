import 'package:floor/floor.dart';
import 'customer.dart';
@Entity(
  tableName: 'measurements',
  foreignKeys: [
    ForeignKey(
      childColumns: ['customerId'],
      parentColumns: ['id'],
      entity: Customer,
    )
  ],
)
class Measurement {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String customerId;
  final String name; // New name field

  /// Stored via TypeConverter as JSON string
  final Map<String, double> measurementValues;

  /// Stored via TypeConverter as ISO string
  final DateTime createdDate;

  final DateTime? updatedDate;
  final DateTime? syncDate; // New field
  final bool isSynced; // New field

  @ignore
  Customer? customer;

  Measurement({
    this.id,
    required this.customerId,
    required this.name, // Add name to constructor
    required this.measurementValues,
    required this.createdDate,
    this.updatedDate,
    this.customer,
    this.syncDate, // Add to constructor
    this.isSynced = false, // Add to constructor with default value
  });

  void linkCustomer(Customer c) {
    customer = c;
  }

  Measurement copyWith({
    int? id,
    String? customerId,
    String? name, // Add name to copyWith
    Map<String, double>? measurementValues,
    DateTime? createdDate,
    DateTime? updatedDate,
    DateTime? syncDate, // Add to copyWith
    bool? isSynced, // Add to copyWith
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
    );
  }
}
