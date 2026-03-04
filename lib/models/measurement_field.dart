import 'package:notdle/models/enum/measurement_category.dart';

class MeasurementField {
  final String name;
  final MeasurementCategory category;

  const MeasurementField({required this.name, required this.category});
}

final List<MeasurementField> femaleMeasurements = [
  /// Upper Body
  MeasurementField(name: "Bust", category: MeasurementCategory.upperBody),
  MeasurementField(
    name: "Niple to Niple",
    category: MeasurementCategory.upperBody,
  ),
  MeasurementField(name: "Under Bust", category: MeasurementCategory.upperBody),
  MeasurementField(name: "Waist", category: MeasurementCategory.upperBody),
  MeasurementField(
    name: "Shoulder to Shoulder",
    category: MeasurementCategory.upperBody,
  ),
  MeasurementField(
    name: "Full Blouse Length",
    category: MeasurementCategory.upperBody,
  ),
  MeasurementField(
    name: "Across Back",
    category: MeasurementCategory.upperBody,
  ),
  MeasurementField(name: "Around Arm", category: MeasurementCategory.upperBody),
  MeasurementField(
    name: "Sleeve Length",
    category: MeasurementCategory.upperBody,
  ),
  MeasurementField(
    name: "Sleeve Measurement",
    category: MeasurementCategory.upperBody,
  ),

  /// Lower Body
  MeasurementField(
    name: "Trouser Waist",
    category: MeasurementCategory.lowerBody,
  ),
  MeasurementField(name: "Thigh", category: MeasurementCategory.lowerBody),
  MeasurementField(name: "Hip", category: MeasurementCategory.lowerBody),
  MeasurementField(name: "Knee", category: MeasurementCategory.lowerBody),
  MeasurementField(name: "Base", category: MeasurementCategory.lowerBody),

  /// Other
  MeasurementField(name: "Cloth Type", category: MeasurementCategory.other),
];

final List<MeasurementField> maleMeasurements = [
  /// Upper Body
  MeasurementField(name: "Chest", category: MeasurementCategory.upperBody),
  MeasurementField(
    name: "Across Back",
    category: MeasurementCategory.upperBody,
  ),
  MeasurementField(name: "Sleeve", category: MeasurementCategory.upperBody),
  MeasurementField(name: "Cuff", category: MeasurementCategory.upperBody),
  MeasurementField(name: "Shirt", category: MeasurementCategory.upperBody),
  MeasurementField(name: "Chin", category: MeasurementCategory.upperBody),

  /// Lower Body
  MeasurementField(name: "Waist", category: MeasurementCategory.lowerBody),
  MeasurementField(name: "Thigh", category: MeasurementCategory.lowerBody),
  MeasurementField(name: "Knee", category: MeasurementCategory.lowerBody),
  MeasurementField(name: "Base", category: MeasurementCategory.lowerBody),
  MeasurementField(name: "Trouser", category: MeasurementCategory.lowerBody),
];

extension MeasurementGrouping on List<MeasurementField> {
  Map<MeasurementCategory, List<MeasurementField>> groupByCategory() {
    final Map<MeasurementCategory, List<MeasurementField>> map = {};

    for (var field in this) {
      map.putIfAbsent(field.category, () => []);
      map[field.category]!.add(field);
    }

    return map;
  }
}
