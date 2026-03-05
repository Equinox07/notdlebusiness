import 'package:flutter/material.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/pages/dashboards/dashboard_app.dart';
import 'package:notdle/pages/dashboards/dashboard_screen.dart';
import 'package:notdle/pages/login_app.dart';
import 'package:notdle/pages/sections/company_services_screen.dart';
import 'package:notdle/screens/add_customer_measurement.dart';
import 'package:notdle/screens/add_customer_screen.dart';
import 'package:notdle/screens/add_measurement_screen.dart';
import 'package:notdle/screens/all_measurement_screen.dart';
import 'package:notdle/screens/company_registration_screen.dart';
import 'package:notdle/screens/create_order_screen.dart';
import 'package:notdle/screens/customer_detail_screen.dart';
import 'package:notdle/screens/customer_measurement.dart';
import 'package:notdle/screens/customers_screen.dart';
import 'package:notdle/screens/deadline_screen.dart';
import 'package:notdle/screens/invoices_screen.dart';
import 'package:notdle/screens/login_page_screen.dart';
import 'package:notdle/screens/main.dart';
import 'package:notdle/screens/notification_screen.dart';
import 'package:notdle/screens/order_details_screen.dart';
import 'package:notdle/screens/client_order_details_screen.dart';
import 'package:notdle/screens/orders_screen.dart';
import 'package:notdle/pages/signup_page.dart';
import 'package:notdle/pages/signup_success_screen.dart';
import 'package:notdle/screens/measurement_detail_page.dart';
import 'package:notdle/screens/profile_screen.dart';
import 'package:notdle/screens/business_profile_screen.dart';
import 'package:notdle/screens/notification_list_screen.dart';
import 'package:notdle/screens/company_profile_screen.dart';
import 'package:notdle/screens/notification_settings_screen.dart';
import 'package:notdle/screens/subscription_billing_screen.dart';
import 'package:notdle/screens/new_measurement_screen.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case CreateOrderScreen.tag:
      //   if (settings.arguments is String) {
      //     return MaterialPageRoute(
      //       builder:
      //           (context) =>
      //               CreateOrderScreen(orderId: settings.arguments as String),
      //     );
      //   }
      //   return null;
      case OrderDetailsScreen.tag:
        if (settings.arguments is Order) {
          return MaterialPageRoute(
            builder:
                (context) => OrderDetailsScreen(
                  order: settings.arguments as Order,
                  orderId: (settings.arguments as Order).id,
                ),
          );
        }
        return null;
      case ClientOrderDetailsScreen.tag:
        if (settings.arguments is Order) {
          return MaterialPageRoute(
            builder:
                (context) => ClientOrderDetailsScreen(
                  order: settings.arguments as Order,
                ),
          );
        }
        return null;
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
      case NewMeasurementScreen.tag:
        if (settings.arguments is Customer) {
          return MaterialPageRoute(
            builder:
                (context) => NewMeasurementScreen(
                  customer: settings.arguments as Customer,
                ),
          );
        }
        return null;
      case DeadlineScreen.tag:
        return MaterialPageRoute(builder: (context) => const DeadlineScreen());
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

  // Navigation helper methods
  static void toMainScreen() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      MainScreen.tag,
      (route) => false,
    );
  }

  // static void toHome2() {
  //   navigatorKey.currentState?.pushReplacement(
  //     MaterialPageRoute(builder: (context) => DashboardScreen()),
  //   );
  // }

  static void toHome2() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      DashboardAppScreen.tag,
      (route) => false,
    );
  }

  static void toLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      LoginApp.tag,
      (route) => false,
    );
  }

  static void toLogin2() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      LoginPageScreen.tag,
      (route) => false,
    );
  }

  static void toSignUp() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      SignupApp.tag,
      (route) => false,
    );
  }

  static void toRegisterCompany() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      CompanyRegistrationScreen.tag,
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

  static void toNotifications() {
    navigatorKey.currentState?.pushNamed(NotificationScreen.tag);
  }

  static void toCompanyServices() {
    navigatorKey.currentState?.pushNamed(CompanyServicesScreen.tag);
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

  static void toCreateOrder({Customer? customer}) {
    navigatorKey.currentState?.pushNamed(
      CreateOrderScreen.tag,
      arguments: customer,
    );
    // if (customer.isNotEmpty) {
    //   navigatorKey.currentState?.pushNamed(
    //     CreateOrderScreen.tag,
    //     arguments: customers,
    //   );
    // } else {
    //   navigatorKey.currentState?.pushNamed(OrdersScreen.tag);
    // }
  }

  static void toMeasurement2({Customer? customer, bool replacement = false}) {
    if (customer != null) {
      if (replacement) {
        navigatorKey.currentState?.pushReplacementNamed(
          CustomerMeasurementScreen.tag,
          arguments: customer,
        );
      } else {
        navigatorKey.currentState?.pushNamed(
          CustomerMeasurementScreen.tag,
          arguments: customer,
        );
      }
    } else {
      navigatorKey.currentState?.pushReplacementNamed(AllMeasurementScreen.tag);
    }
  }

  static void toMeasurement3({Customer? customer}) {
    if (customer != null) {
      navigatorKey.currentState?.pushNamed(
        AddCustomerMeasurementScreen.tag,
        arguments: customer,
      );
    } else {
      navigatorKey.currentState?.pushNamed(AllMeasurementScreen.tag);
    }
  }

  static void toNewMeasurement(Customer customer) {
    navigatorKey.currentState?.pushNamed(
      NewMeasurementScreen.tag,
      arguments: customer,
    );
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

  static void toOrderDetails({String? orderId}) {
    if (orderId != null) {
      navigatorKey.currentState?.pushNamed(
        OrderDetailsScreen.tag,
        arguments: orderId,
      );
    } else {
      navigatorKey.currentState?.pushNamed(OrderDetailsScreen.tag);
    }
  }

  static void toAddCustomer() {
    navigatorKey.currentState?.pushNamed(AddCustomerScreen.tag);
  }

  static void toCreateNewOrder() {
    navigatorKey.currentState?.pushNamed(CreateOrderScreen.tag);
  }

  static void toInvoice() {
    navigatorKey.currentState?.pushNamed(InvoicesScreen.tag);
  }

  static void toProfile() {
    navigatorKey.currentState?.pushNamed(ProfileScreen.tag);
  }

  static void toBusinessProfile() {
    navigatorKey.currentState?.pushNamed(BusinessProfileScreen.tag);
  }

  static void toCompanyProfile() {
    navigatorKey.currentState?.pushNamed(CompanyProfileScreen.tag);
  }

  static void toNotificationSettings() {
    navigatorKey.currentState?.pushNamed(NotificationSettingsScreen.tag);
  }

  static void toSubscriptionBilling() {
    navigatorKey.currentState?.pushNamed(SubscriptionBillingScreen.tag);
  }

  static void toNotificationList() {
    navigatorKey.currentState?.pushNamed(NotificationListScreen.tag);
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

  static void toDeadlines() {
    navigatorKey.currentState?.pushNamed(DeadlineScreen.tag);
  }

  static void back() {
    navigatorKey.currentState?.pop();
  }
}

class RandomScreen extends StatelessWidget {
  const RandomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
