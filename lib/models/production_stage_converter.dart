import 'package:floor/floor.dart';
import 'package:notdle/models/order.dart';

class ProductionStageConverter extends TypeConverter<ProductionStage, String> {
  @override
  ProductionStage decode(String databaseValue) {
    return ProductionStage.values.firstWhere(
      (e) => e.toString() == databaseValue,
      orElse: () => ProductionStage.measure,
    );
  }

  @override
  String encode(ProductionStage value) {
    return value.toString();
  }
}
