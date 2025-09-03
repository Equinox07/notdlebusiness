

import 'package:flutter/material.dart';
import 'package:notdle/pages/dashboard_screen.dart';
import 'package:notdle/pages/landing_page.dart';
import 'package:notdle/pages/login_screen.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: ''),
      home: DashboardScreen(),
      initialRoute: DashboardScreen.tag,
      routes: {
        DashboardScreen.tag: (context) => const DashboardScreen()
      },
    );
  }
}