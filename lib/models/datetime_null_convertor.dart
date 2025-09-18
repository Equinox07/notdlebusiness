import 'package:floor/floor.dart';

class DateTimeNullConvertor extends TypeConverter<DateTime?, int?> {
  @override
  DateTime? decode(int? databaseValue) {
    if (databaseValue == null) return null;
    return DateTime.fromMicrosecondsSinceEpoch(databaseValue);
  }

  @override
  int? encode(DateTime? value) {
    return value?.microsecondsSinceEpoch;
  }
}
