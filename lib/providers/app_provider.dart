import 'package:flutter/material.dart';
import 'package:notdle/db/app_database.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/dao/company_dao.dart';
import 'package:notdle/models/dao/customer_dao.dart';
import 'package:notdle/models/dao/measurement_dao.dart';
import 'package:notdle/models/dao/order_dao.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/models/order.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// import '../data/app_database.dart'; // Your Floor database
// import '../data/order_dao.dart';

class AppProvider extends ChangeNotifier {
  late final AppDatabase _db;

  CompanyDao get companyDao => _db.companyDao;
  CustomerDao get customerDao => _db.customerDao;
  OrderDao get orderDao => _db.orderDao;
  MeasurementDao get measurementDao => _db.measurementDao;


  Future<void> init() async {
    // 1. Get the documents directory path
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDir.path, 'app_database.db');

    // // 2. Check if DB already exists; if not, copy from assets
    // final dbFile = File(dbPath);
    // if (!await dbFile.exists()) {
    //   print('[AppProvider] Copying pre-populated database from assets...');
    //   final byteData = await rootBundle.load('assets/db/app_database.db');
    //   await dbFile.writeAsBytes(
    //     byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    //     flush: true,
    //   );
    // }

    // 3. Initialize Floor with the copied database
    _db = await $FloorAppDatabase.databaseBuilder(dbPath).build();

    // Seed Company
    final existingCompany = await companyDao.getCompany();
    if (existingCompany == null) {
      final company = Company(
        id: const Uuid().v4(),
        ownerName: 'Jane Doe',
        email: 'jane@biz.com',
        mobile: '+123456789',
        businessName: 'Jane\'s Co.',
        yearsOfExperience: 8,
        registrationNumber: 'COMP1234',
        address: '123 Main Street',
        countryCode: 'US',
        imagePath: null,
        logoUrl: null,
      );
      await companyDao.insertCompany(company);
    }

    // Seed one Customer
    final customers = await customerDao.getAllCustomers();
    if (customers.isEmpty) {
      final newCustomer = Customer(
        id: const Uuid().v4(),
        name: 'Alice Johnson',
        phone: '+1234567890',
        email: 'alice@example.com',
        gender: 'female',
        address: '123 Elm Street',
        lastVisit: DateTime.now(),
        createdDate: DateTime.now(),
      );

      await customerDao.insertCustomer(newCustomer);

      // Seed one Order
      final newOrder = Order(
        id: const Uuid().v4(),
        title: 'Logo Design Project',
        customerId: newCustomer.id!,
        status: 'Pending',
        paymentStatus: 'Unpaid',
        paymentAmount: 150.0,
        dueDate: DateTime.now().add(Duration(days: 7)).toIso8601String(),
        notes: 'High priority client',
        createdDate: DateTime.now().toIso8601String(),
      );

      await orderDao.insertOrder(newOrder);


      final measurement = Measurement(
        customerId: newCustomer.id!,
        measurementValues: {
          'waist': 34.0,
          'chest': 40.0,
          'inseam': 32.5,
        },
        createdDate: DateTime.now(), name: '',
      );

      await measurementDao.insertMeasurement(measurement);

    }

    notifyListeners();
  }
}
