import 'package:flutter/material.dart';
import 'package:notdle/models/dao/customer_dao.dart';
import 'package:notdle/models/dao/measurement_dao.dart';
import '../models/measurement.dart';

class MeasurementProvider extends ChangeNotifier {
  final MeasurementDao measurementDao;
  final CustomerDao customerDao;

  MeasurementProvider({
    required this.measurementDao,
    required this.customerDao,
  });

  List<Measurement> _customerMeasurements = [];
  List<Measurement> get customerMeasurements => _customerMeasurements;

  List<Measurement> _measurements = [];

  List<Measurement> get measurements => _measurements;

  Future<Measurement> addMeasurement(Measurement measurement) async {
    // final saved = await repository.addMeasurement(m);
    // _measurements.add(saved);
    await measurementDao.insertMeasurement(measurement);
    notifyListeners();
    return measurement;
  }

  Future<void> updateMeasurement(Measurement measurement) async {
    // await repository.updateMeasurement(m);
    await measurementDao.updateMeasurement(measurement);
    final index = _measurements.indexWhere((e) => e.id == measurement.id);
    if (index != -1) {
      _measurements[index] = measurement;
      notifyListeners();
    }
  }

  Future<void> fetchMeasurementsWithCustomer(String customerId) async {
    try {
      final measurements = await measurementDao.getMeasurementsForCustomer(
        customerId,
      );
      final customer = await customerDao.getCustomerById(customerId);

      if (customer != null) {
        for (var m in measurements) {
          m.linkCustomer(customer);
        }
      }

      _customerMeasurements = measurements;
      notifyListeners();
    } catch (e) {
      print('Error fetching measurements: $e');
    }
  }

  Future<List<Measurement>> getAllMeasurementsWithCustomers() async {
    final measurements = await measurementDao.getAllMeasurements();

    for (final m in measurements) {
      final customer = await customerDao.getCustomerById(m.customerId);
      if (customer != null) {
        m.linkCustomer(customer);
      }
    }

    return measurements;
  }

  Future<List<Measurement>> getAllMeasurementWithCustomers() async {
    final measurements = await measurementDao.getAllMeasurements();
    final allCustomers = await customerDao.getAllCustomers();

    final customerMap = {for (final c in allCustomers) c.id: c};

    for (final m in measurements) {
      final customer = customerMap[m.customerId];
      if (customer != null) {
        m.linkCustomer(customer);
      }
    }

    return measurements;
  }

  Future<void> getAllMeasurementWithCustomer() async {
    final measurements = await measurementDao.getAllMeasurements();
    final allCustomers = await customerDao.getAllCustomers();

    final customerMap = {for (final c in allCustomers) c.id: c};

    for (final m in measurements) {
      final customer = customerMap[m.customerId];
      if (customer != null) {
        m.linkCustomer(customer);
      }
    }

    _measurements = measurements;
    notifyListeners();

    // return measurements;
  }

  // Future<List<Measurement>> getAllMeasurementWithCustomers() async {
  //   final measurements = await measurementDao.getAllMeasurements();
  //
  //   // Get all unique customer IDs
  //   final customerIds = measurements
  //       .map((m) => m.customerId)
  //       .toSet()
  //       .toList();
  //
  //   // Fetch all customers in one go
  //   final customers = await customerDao.getCustomersByIds(customerIds);
  //
  //   // Map customers by ID for quick lookup
  //   final customerMap = {
  //     for (final c in customers) c.id: c
  //   };
  //
  //   // Link customers
  //   for (final m in measurements) {
  //     final customer = customerMap[m.customerId];
  //     if (customer != null) {
  //       m.linkCustomer(customer);
  //     }
  //   }
  //
  //   return measurements;
  // }

  void clear() {
    _customerMeasurements = [];
    notifyListeners();
  }
}
