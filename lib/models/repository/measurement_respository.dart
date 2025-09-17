

import 'package:notdle/models/dao/measurement_dao.dart';
import 'package:notdle/models/measurement.dart';

class MeasurementRepository {
  final MeasurementDao dao;

  MeasurementRepository({required this.dao});

  Future<Measurement> addMeasurement(Measurement measurement) async {
    final id = await dao.insertMeasurement(measurement);
    return measurement.copyWith(id: id);
  }

  Future<List<Measurement>> getCustomerMeasurements(String customerId) {
    return dao.getMeasurementsByCustomerId(customerId);
  }

  Future<Measurement?> getMeasurementById(int id) {
    return dao.getMeasurementById(id);
  }

  Future<void> updateMeasurement(Measurement measurement) {
    return dao.updateMeasurement(measurement);
  }

  Future<void> deleteMeasurement(Measurement measurement) {
    return dao.deleteMeasurement(measurement);
  }

  Future<void> deleteMeasurementsByCustomer(String customerId) {
    return dao.deleteMeasurementsByCustomerId(customerId);
  }
}
