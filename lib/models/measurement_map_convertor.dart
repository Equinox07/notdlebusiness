import 'dart:convert';

import 'package:floor/floor.dart';

class MeasurementMapConverter extends TypeConverter<Map<String, double>, String> {
  @override
  Map<String, double> decode(String databaseValue) {
    final Map<String, dynamic> decoded = jsonDecode(databaseValue);
    return decoded.map((key, value) => MapEntry(key, (databaseValue as num).toDouble()));
  }

  @override
  String encode(Map<String, double> value) {
    return jsonEncode(value);
  }

  // @TypeConverter()
  // String fromMap(Map<String, double> map) => jsonEncode(map);
  //
  // @TypeConverter()
  // Map<String, double> toMap(String json) {
  //   final Map<String, dynamic> decoded = jsonDecode(json);
  //   return decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
  // }
}
