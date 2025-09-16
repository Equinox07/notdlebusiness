import 'package:flutter/material.dart';
import 'package:notdle/pages/index_page.dart';
import 'package:notdle/pages/login_app.dart';
import 'package:notdle/pages/signup_page.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:notdle/providers/dashboard_provider.dart';
import 'package:notdle/providers/notification_provider.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:provider/provider.dart';
// import 'package:notdle/pages/index_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CompanyProvider()),
        ChangeNotifierProvider(create: (context) => DashBoardProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: const IndexPage(),
    ),
  );
}

