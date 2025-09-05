import 'package:flutter/material.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/pages/dashboard_screen.dart';
import 'package:notdle/pages/landing_page.dart';
import 'package:notdle/pages/login_app.dart';
import 'package:notdle/pages/login_screen.dart';
import 'package:notdle/pages/screens/add_customer_screen.dart';
import 'package:notdle/pages/screens/add_measurement_screen.dart';
import 'package:notdle/pages/screens/all_measurement_screen.dart';
import 'package:notdle/pages/screens/create_order_screen.dart';
import 'package:notdle/pages/screens/customers_screen.dart';
import 'package:notdle/pages/screens/order_details_screen.dart';
import 'package:notdle/pages/screens/orders_screen.dart';
import 'package:notdle/pages/signup_page.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: ''),
      home: LoginApp(),
      navigatorKey: AppNavigator.navigatorKey,
      initialRoute: LoginApp.tag,
      onGenerateRoute: AppNavigator.onGenerateRoute,
      routes: {
        LoginApp.tag: (context) => const LoginApp(),
        SignupApp.tag: (context) => const SignupApp(),
        CustomersScreen.tag: (context) => const CustomersScreen(),
        AllMeasurementScreen.tag: (context) => const AllMeasurementScreen(),
        AddCustomerScreen.tag: (context) => const AddCustomerScreen(),
        DashboardScreen.tag: (context) => const DashboardScreen(),
        OrdersScreen.tag: (context) => const OrdersScreen(),
        // CreateOrderScreen.tag: (context) => const CreateOrderScreen(),
        // OrderDetailsScreen.tag: (context) => const OrderDetailsScreen(),
      },
    );
  }
}
