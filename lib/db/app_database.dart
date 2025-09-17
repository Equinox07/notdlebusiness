// lib/db/app_database.dart

import 'dart:async';
import 'package:floor/floor.dart';
import 'package:notdle/models/dao/company_dao.dart';
import 'package:notdle/models/dao/customer_dao.dart';
import 'package:notdle/models/dao/invoice_dao.dart';
import 'package:notdle/models/dao/measurement_dao.dart';
import 'package:notdle/models/dao/order_dao.dart';
import 'package:notdle/models/datetime_convertor.dart';
import 'package:notdle/models/datetime_null_convertor.dart';
import 'package:notdle/models/measurement_map_convertor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:notdle/models/company.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/models/invoice.dart';

part 'app_database.g.dart'; // The file that will be generated

@TypeConverters([DateTimeConvertor, MeasurementMapConverter, DateTimeNullConvertor])
@Database(version: 1, entities: [Company, Customer, Order, Measurement, Invoice])
abstract class AppDatabase extends FloorDatabase {
  CompanyDao get companyDao;
  CustomerDao get  customerDao;
  OrderDao get orderDao;
  MeasurementDao get measurementDao;
  InvoiceDao get invoiceDao;
}