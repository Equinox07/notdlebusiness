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

  /// Stored via TypeConverter as JSON string
  final Map<String, double> measurementValues;

  /// Stored via TypeConverter as ISO string
  final DateTime createdDate;

  final DateTime? updatedDate;

  @ignore
  Customer? customer;

  Measurement({
    this.id,
    required this.customerId,
    required this.measurementValues,
    required this.createdDate,
    this.updatedDate,
    this.customer,
  });

  void linkCustomer(Customer c) {
    customer = c;
  }

  Measurement copyWith({
    int? id,
    String? customerId,
    Map<String, double>? measurementValues,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return Measurement(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      measurementValues: measurementValues ?? this.measurementValues,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      customer: customer,
    );
  }
}
