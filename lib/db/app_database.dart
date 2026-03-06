// lib/db/app_database.dart

import 'dart:async';
import 'package:floor/floor.dart';
import 'package:notdle/models/dao/app_image_dao.dart';
import 'package:notdle/models/dao/company_dao.dart';
import 'package:notdle/models/dao/customer_dao.dart';
import 'package:notdle/models/dao/invoice_dao.dart';
import 'package:notdle/models/dao/measurement_dao.dart';
import 'package:notdle/models/dao/order_dao.dart';
import 'package:notdle/models/dao/project_dao.dart';
import 'package:notdle/models/dao/payment_dao.dart';
import 'package:notdle/models/datetime_convertor.dart';
import 'package:notdle/models/datetime_null_convertor.dart';
import 'package:notdle/models/invoice_item.dart';
import 'package:notdle/models/measurement_map_convertor.dart';
import 'package:notdle/models/order_item.dart';
import 'package:notdle/models/payment.dart';
import 'package:notdle/models/string_list_converter.dart';
import 'package:notdle/models/production_stage_converter.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:notdle/models/company.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/project_model.dart';
import 'package:notdle/models/app_image.dart';

part 'app_database.g.dart'; // The file that will be generated

@TypeConverters([
  DateTimeConvertor,
  MeasurementMapConverter,
  DateTimeNullConvertor,
  StringListConverter,
  ProductionStageConverter,
])
@Database(
  version: 9, // Increment version for schema changes
  entities: [
    Company,
    Customer,
    Order,
    Measurement,
    Invoice,
    Payment,
    OrderItem,
    InvoiceItem,
    Project,
    AppImage,
  ],
)
abstract class AppDatabase extends FloorDatabase {
  CompanyDao get companyDao;
  CustomerDao get customerDao;
  OrderDao get orderDao;
  MeasurementDao get measurementDao;
  InvoiceDao get invoiceDao;
  ProjectDao get projectDao;
  PaymentDao get paymentDao;
  AppImageDao get appImageDao;

  Future<void> truncateAllTables() async {
    await (database as sqflite.Database).transaction((txn) async {
      await txn.execute('DELETE FROM invoice_items');
      await txn.execute('DELETE FROM order_items');
      await txn.execute('DELETE FROM payments');
      await txn.execute('DELETE FROM invoices');
      await txn.execute('DELETE FROM measurements');
      await txn.execute('DELETE FROM orders');
      await txn.execute('DELETE FROM projects');
      await txn.execute('DELETE FROM customers');
      await txn.execute('DELETE FROM company');
      await txn.execute(
        "DELETE FROM sqlite_sequence WHERE name='measurements'",
      );
      await txn.execute('DELETE FROM app_images');
    });
  }
}
