

import 'package:floor/floor.dart';

class DateTimeConvertor extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMicrosecondsSinceEpoch(databaseValue);
  }

  @override
  int encode(DateTime value) {
    return value.microsecondsSinceEpoch;
  }

}