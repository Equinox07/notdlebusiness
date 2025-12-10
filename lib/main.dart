import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:notdle/db/app_database.dart';
import 'package:notdle/pages/index_page.dart';
import 'package:notdle/providers/app_provider.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/dashboard_provider.dart';
import 'package:notdle/providers/invoice_provider.dart';
import 'package:notdle/providers/measurement_provider.dart';
import 'package:notdle/providers/notification_provider.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding =  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final db = await $FloorAppDatabase.databaseBuilder('app_database').build();

  final appProvider = AppProvider();
  await appProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()..init()),
        ChangeNotifierProvider(
          create:
              (_) => MeasurementProvider(
                measurementDao: db.measurementDao,
                customerDao: db.customerDao,
              ),
        ),
        ChangeNotifierProvider(create: (context) => OrderProvider(orderDao: db.orderDao)),
        ChangeNotifierProvider(create: (context) => CustomerProvider(customerDao: db.customerDao, orderDao: db.orderDao)),
        ChangeNotifierProvider(create: (context) => InvoiceProvider(invoiceDao: db.invoiceDao)),
        ChangeNotifierProvider(create: (context) => CompanyProvider(companyDao: db.companyDao)),
        ChangeNotifierProvider(create: (context) => DashBoardProvider(orderDao: db.orderDao, customerDao: db.customerDao)),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: const IndexPage(),
    ),
  );

  FlutterNativeSplash.remove();
}

