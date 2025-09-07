import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/pages/screens/customers_screen.dart';
import 'package:notdle/pages/screens/fabric_screen.dart';
import 'package:notdle/pages/screens/invoices_screen.dart';
import 'package:notdle/pages/screens/orders_screen.dart';
import 'package:notdle/pages/screens/projects_screen.dart';
import 'package:notdle/pages/screens/services_screen.dart';
import 'package:notdle/pages/sections/appointment_card.dart';
import 'package:notdle/pages/sections/dashboard_home.dart';
import 'package:notdle/pages/sections/insight_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const String tag = "dashboard";

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardHome(),
    CustomersScreen(),
    OrdersScreen(),
    // FabricsScreen(),
    InvoicesScreen(),
    // ServicesScreen(),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed, // ✅ allows 6 tabs
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Clients"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: "Invoices",
          ),
          // BottomNavigationBarItem(icon: Icon(Icons.texture), label: "Invoices"),
          // BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Invoices"),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.design_services), label: "Services"),
        ],
      ),
    );
  }
}

//
// ----------------- DASHBOARD HOME -----------------
//

//
// ----------------- OTHER MAIN SCREENS -----------------
//
class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clients")),
      body: const Center(child: Text("Clients list & appointments here")),
    );
  }
}
