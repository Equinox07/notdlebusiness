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
import 'package:notdle/screens/data_page.dart';
import 'package:notdle/screens/invoices_screen.dart';
import 'package:notdle/screens/login_page_screen.dart';
import 'package:notdle/screens/forget_password_screen.dart';
import 'package:notdle/screens/personal_account_screen.dart';
import 'package:notdle/screens/create_business_account_screen.dart';
import 'package:notdle/screens/initial_setup_screen.dart';
import 'package:notdle/screens/main.dart';
import 'package:notdle/screens/notification_screen.dart';
import 'package:notdle/screens/orders_screen.dart';
import 'package:notdle/pages/signup_page.dart';
import 'package:notdle/screens/profile_screen.dart';
import 'package:notdle/screens/settings_screen.dart';
import 'package:notdle/screens/onboarding_screen.dart';
import 'package:notdle/services/api_service.dart';
import 'package:notdle/utils/version_helper.dart';
import 'package:notdle/widgets/force_update_modal.dart';
import 'package:notdle/models/app_version.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        ForgetPasswordScreen.tag: (context) => const ForgetPasswordScreen(),
        PersonalAccountScreen.tag: (context) => const PersonalAccountScreen(),
        CreateBusinessAccountScreen.tag:
            (context) => const CreateBusinessAccountScreen(),
        InitialSetupScreen.tag: (context) => const InitialSetupScreen(),
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
        CompanyServicesScreen.tag: (context) => CompanyServicesScreen(),
        SettingsScreen.tag: (context) => const SettingsScreen(),
        DataPage.tag: (context) => const DataPage(),
        OnboardingScreen.tag: (context) => const OnboardingScreen(),
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
      // 1. Check for Force Update first
      final updateInfo = await VersionHelper.checkUpdate();
      if (updateInfo['shouldUpdate'] == true &&
          updateInfo['forceUpdate'] == true) {
        final latestInfo = updateInfo['latestVersion'] as AppVersionDto;
        return Scaffold(
          body: Center(
            child: ForceUpdateModal(
              latestVersion: latestInfo.version,
              releaseNotes: latestInfo.releaseNotes,
            ),
          ),
        );
      }

      // Check if onboarding has been seen
      final prefs = await SharedPreferences.getInstance();
      final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

      if (!seenOnboarding) {
        return const OnboardingScreen();
      }

      // Check if we have a stored user
      final user = await _apiService.getStoredUser();

      if (user == null) {
        // No user found, go to login
        return const LoginPageScreen();
      }

      // User found, check if they have a company
      if (!user.hasCompany) {
        // No company, go to company registration
        return CreateBusinessAccountScreen();
        // return CompanyRegistrationScreen();
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
