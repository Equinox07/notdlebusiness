import 'dart:convert';
import 'package:floor/floor.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  @override
  List<String> decode(String databaseValue) {
    return (json.decode(databaseValue) as List<dynamic>)
        .map((item) => item.toString())
        .toList();
  }

  @override
  String encode(List<String> value) {
    return json.encode(value);
  }
}
