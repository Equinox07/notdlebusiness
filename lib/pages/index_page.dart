import 'package:flutter/material.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/pages/dashboards/dashboard_app.dart';
import 'package:notdle/pages/dashboards/dashboard_screen.dart';
import 'package:notdle/pages/login_app.dart';
import 'package:notdle/screens/add_customer_screen.dart';
import 'package:notdle/screens/all_measurement_screen.dart';
import 'package:notdle/screens/company_registration_screen.dart';
import 'package:notdle/screens/create_order_screen.dart';
import 'package:notdle/screens/customers_screen.dart';
import 'package:notdle/screens/invoices_screen.dart';
import 'package:notdle/screens/login_page_screen.dart';
import 'package:notdle/screens/main.dart';
import 'package:notdle/screens/notification_screen.dart';
import 'package:notdle/screens/orders_screen.dart';
import 'package:notdle/pages/signup_page.dart';
import 'package:notdle/screens/profile_screen.dart';
import 'package:notdle/services/session_manager.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: ''),
      home: _StartupScreen(),
      navigatorKey: AppNavigator.navigatorKey,
      initialRoute: LoginApp.tag,
      onGenerateRoute: AppNavigator.onGenerateRoute,
      routes: {
        LoginPageScreen.tag: (context) => const LoginPageScreen(),
        CompanyRegistrationScreen.tag:
            (context) => const CompanyRegistrationScreen(),
        SignupApp.tag: (context) => const SignupApp(),
        CustomersScreen.tag: (context) => const CustomersScreen(),
        AllMeasurementScreen.tag: (context) => const AllMeasurementScreen(),
        AddCustomerScreen.tag: (context) => const AddCustomerScreen(),
        DashboardScreen.tag: (context) => const DashboardScreen(),
        DashboardAppScreen.tag: (context) => const DashboardAppScreen(),
        OrdersScreen.tag: (context) => const OrdersScreen(),
        MainScreen.tag: (context) => const MainScreen(),
        ProfileScreen.tag: (context) => const ProfileScreen(),
        CreateOrderScreen.tag: (context) => const CreateOrderScreen(),
        InvoicesScreen.tag: (context) => const InvoicesScreen(),
        NotificationScreen.tag: (context) => const NotificationScreen(),
        // CreateOrderScreen.tag: (context) => const CreateOrderScreen(),
        // OrderDetailsScreen.tag: (context) => const OrderDetailsScreen(),
      },
    );
  }
}


class _StartupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SessionManager.getCompany(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading screen while checking shared preferences
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData) {
          // If company data exists, navigate to the main screen
          return const DashboardScreen();
          //DashboardAppScreen
        } else {
          // If no company data, navigate to the login screen
          return const LoginPageScreen();
        }
      },
    );
  }
}