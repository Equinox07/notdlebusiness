import 'package:flutter/material.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
      '/login',
      (route) => false,
    );
  }

  static void toCustomers() {
    navigatorKey.currentState?.pushNamed('/customers');
  }

  // static void toCustomerDetails(Customer customer) {
  //   navigatorKey.currentState?.pushNamed(
  //     '/customer-details',
  //     arguments: customer,
  //   );
  // }

  // static void toMeasurement({Customer? customer}) {
  //   if (customer != null) {
  //     navigatorKey.currentState?.pushNamed(
  //       '/measurement-with-customer',
  //       arguments: customer,
  //     );
  //   } else {
  //     navigatorKey.currentState?.pushNamed('/measurement');
  //   }
  // }

  static void toAddCustomer() {
    navigatorKey.currentState?.pushNamed('/add-customer');
  }

  static void toOrders() {
    navigatorKey.currentState?.pushNamed('/orders');
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