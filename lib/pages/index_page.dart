

import 'package:flutter/material.dart';
import 'package:notdle/pages/landing_page.dart';
import 'package:notdle/pages/login_screen.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: ''),
      home: LoginScreen(),
      initialRoute: LoginScreen.tag,
      routes: {
        LoginScreen.tag: (context) => const LoginScreen()
      },
    );
  }
}