import 'package:flutter/material.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/pages/dashboards/dashboard_app.dart';
import 'package:notdle/pages/dashboards/dashboard_screen.dart';
import 'package:notdle/pages/login_app.dart';
import 'package:notdle/pages/sections/company_services_screen.dart';
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
import 'package:notdle/services/api_service.dart';
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
        CompanyServicesScreen.tag: (context) => CompanyServicesScreen(),
        // CreateOrderScreen.tag: (context) => const CreateOrderScreen(),
        // OrderDetailsScreen.tag: (context) => const OrderDetailsScreen(),
      },
    );
  }
}


class _StartupScreen extends StatelessWidget {
  final ApiService _apiService = ApiService();

  Future<Widget> _determineInitialRoute() async {
    try {
      // Check if we have a stored user
      final user = await _apiService.getStoredUser();
      
      if (user == null) {
        // No user found, go to login
        return const LoginPageScreen();
      }
      
      // User found, check if they have a company
      if (!user.hasCompany) {
        // No company, go to company registration
        return CompanyRegistrationScreen();
      }
      
      // User has a company, go to dashboard
      return const DashboardScreen();
    } catch (e) {
      // In case of any error, default to login screen
      debugPrint('Error determining initial route: $e');
      return const LoginPageScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _determineInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading screen while determining the route
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          // If there's an error, show login screen as fallback
          return const LoginPageScreen();
        } else {
          // Return the determined route
          return snapshot.data ?? const LoginPageScreen();
        }
      },
    );
  }
}