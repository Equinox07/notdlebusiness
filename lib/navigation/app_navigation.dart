import 'package:flutter/material.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/pages/dashboard_screen.dart';
import 'package:notdle/pages/login_app.dart';
import 'package:notdle/pages/screens/add_customer_screen.dart';
import 'package:notdle/pages/screens/add_measurement_screen.dart';
import 'package:notdle/pages/screens/all_measurement_screen.dart';
import 'package:notdle/pages/screens/customer_detail_screen.dart';
import 'package:notdle/pages/screens/customer_measurement.dart';
import 'package:notdle/pages/screens/customers_screen.dart';
import 'package:notdle/pages/screens/order_details_screen.dart';
import 'package:notdle/pages/screens/orders_screen.dart';
import 'package:notdle/pages/signup_page.dart';
import 'package:notdle/pages/signup_success_screen.dart';
import 'package:notdle/pages/screens/measurement_detail_page.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case OrderDetailsScreen.tag:
      //   if (settings.arguments is Customer) {
      //     return MaterialPageRoute(builder: (context) => OrderDetailsScreen());
      //   }
      //   return null;
      case CustomerDetailScreen.tag:
        if (settings.arguments is Customer) {
          return MaterialPageRoute(
            builder:
                (context) => CustomerDetailScreen(
                  customer: settings.arguments as Customer,
                ),
          );
        }
        return null;
      case MeasurementDetailPage.tag:
        if (settings.arguments is Measurement) {
          return MaterialPageRoute(
            builder:
                (context) => MeasurementDetailPage(
                  measurement: settings.arguments as Measurement,
                ),
          );
        }
        return null;
      case CustomerMeasurementScreen.tag:
        if (settings.arguments is Customer) {
          return MaterialPageRoute(
            builder:
                (context) => CustomerMeasurementScreen(
                  customer: settings.arguments as Customer,
                ),
          );
        }
        return null;
      default:
        return null;
    }
  }

  // Navigation helper methods
  static void toHome() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      DashboardScreen.tag,
      (route) => false,
    );
  }

  static void toLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      LoginApp.tag,
      (route) => false,
    );
  }

  static void toSignUp() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      SignupApp.tag,
      (route) => false,
    );
  }

  static void toSignUpSuccess() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      SignupSuccessScreen.tag,
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

  static void toMeasurement2({Customer? customer}) {
    if (customer != null) {
      navigatorKey.currentState?.pushNamed(
        CustomerMeasurementScreen.tag,
        arguments: customer,
      );
    } else {
      navigatorKey.currentState?.pushNamed(AllMeasurementScreen.tag);
    }
  }

  static void toMeasurementDetails({Measurement? measurement}) {
    if (measurement != null) {
      navigatorKey.currentState?.pushNamed(
        MeasurementDetailPage.tag,
        arguments: measurement,
      );
    } else {
      navigatorKey.currentState?.pushNamed(AllMeasurementScreen.tag);
    }
  }

  static void toOrderDetails({Measurement? measurement}) {
    if (measurement != null) {
      navigatorKey.currentState?.pushNamed(
        OrderDetailsScreen.tag,
        arguments: measurement,
      );
    } else {
      navigatorKey.currentState?.pushNamed(OrderDetailsScreen.tag);
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
