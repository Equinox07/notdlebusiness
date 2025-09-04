import 'package:flutter/material.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/pages/login_app.dart';
import 'package:notdle/pages/screens/add_customer_screen.dart';
import 'package:notdle/pages/screens/add_measurement_screen.dart';
import 'package:notdle/pages/screens/all_measurement_screen.dart';
import 'package:notdle/pages/screens/customer_details_screen.dart';
import 'package:notdle/pages/screens/customers_screen.dart';
import 'package:notdle/pages/screens/orders_screen.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case '/customer-details':
      //   if (settings.arguments is Customer) {
      //     return MaterialPageRoute(
      //       builder: (context) => CustomerDetailsScreen(
      //         customer: settings.arguments as Customer,
      //       ),
      //     );
      //   }
      //   return null;
      // case '/measurement-with-customer':
      //   if (settings.arguments is Customer) {
      //     return MaterialPageRoute(
      //       builder: (context) => CustomerMeasurementScreen(
      //         customer: settings.arguments as Customer,
      //       ),
      //     );
      //   }
      //   return null;
      // default:
      //   return null;
    }
  }

  // Navigation helper methods
  static void toHome() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );
  }

  static void toLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      LoginApp.tag,
      (route) => false,
    );
  }

  static void toCustomers() {
    navigatorKey.currentState?.pushNamed(CustomersScreen.tag);
  }

  static void toCustomerDetails(Customer customer) {
    navigatorKey.currentState?.pushNamed(
      CustomerDetailScreen.tag,
      arguments: customer,
    );
  }

  static void toMeasurement({Customer? customer}) {
    if (customer != null) {
      navigatorKey.currentState?.pushNamed(
        AddMeasurementScreen.tag,
        arguments: customer,
      );
    } else {
      navigatorKey.currentState?.pushNamed(AllMeasurementScreen.tag);
    }
  }

  static void toAddCustomer() {
    navigatorKey.currentState?.pushNamed(AddCustomerScreen.tag);
  }

  static void toOrders() {
    navigatorKey.currentState?.pushNamed(OrdersScreen.tag);
  }

  static void toDesigns() {
    navigatorKey.currentState?.pushNamed('/designs');
  }

  static void toPersonalInfo() {
    navigatorKey.currentState?.pushNamed('/personal-info');
  }

  static void toSettings() {
    navigatorKey.currentState?.pushNamed('/settings');
  }

  static void back() {
    navigatorKey.currentState?.pop();
  }
}

class RandomeScreen extends StatelessWidget {
  const RandomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
