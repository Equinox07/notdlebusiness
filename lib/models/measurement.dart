class Measurement {
  final int customerId;
  final Map<String, double> values;
  final DateTime createdDate; // 🔹 New

  Measurement({
    required this.customerId,
    required this.values,
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'values': values.map((k, v) => MapEntry(k, v.toString())),
      'createdDate': createdDate.toIso8601String(), // 🔹 Save
    };
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    final values = <String, double>{};
    (map['values'] as Map<String, dynamic>).forEach((key, value) {
      values[key] = double.tryParse(value.toString()) ?? 0.0;
    });

    return Measurement(
      customerId: map['customerId'],
      values: values,
      createdDate: DateTime.parse(map['createdDate']), // 🔹 Load
    );
  }
}
