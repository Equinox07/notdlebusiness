import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/pages/sections/company_services_screen.dart';
import 'package:notdle/screens/customers_screen.dart';
import 'package:notdle/screens/fabric_screen.dart';
import 'package:notdle/screens/invoices_screen.dart';
import 'package:notdle/screens/orders_screen.dart';
import 'package:notdle/screens/profile_screen.dart';
import 'package:notdle/screens/projects_screen.dart';
import 'package:notdle/screens/services_screen.dart';
import 'package:notdle/pages/sections/appointment_card.dart';
import 'package:notdle/pages/dashboards/dashboard_home.dart';
import 'package:notdle/pages/sections/insight_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const String tag = "dashboard";

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardHome(),
    const CustomersScreen(),
    const ServicesScreen(),
    const OrdersScreen(),
    const InvoicesScreen(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onNavTapped(2), // 2 is the index for Services
        backgroundColor: Colors.indigo.shade600,
        child: const Icon(Icons.design_services, color: Colors.white, size: 30),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8.0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => _onNavTapped(0),
              icon: Icon(
                Icons.dashboard,
                color: _selectedIndex == 0 ? Colors.indigo.shade600 : Colors.grey.shade600,
              ),
              tooltip: 'Dashboard',
            ),
            IconButton(
              onPressed: () => _onNavTapped(1),
              icon: Icon(
                Icons.people,
                color: _selectedIndex == 1 ? Colors.indigo.shade600 : Colors.grey.shade600,
              ),
              tooltip: 'Clients',
            ),
            const SizedBox(width: 48), // Spacer for the FAB
            IconButton(
              onPressed: () => _onNavTapped(3),
              icon: Icon(
                Icons.shopping_cart,
                color: _selectedIndex == 3 ? Colors.indigo.shade600 : Colors.grey.shade600,
              ),
              tooltip: 'Orders',
            ),
            IconButton(
              onPressed: () => _onNavTapped(4),
              icon: Icon(
                Icons.attach_money,
                color: _selectedIndex == 4 ? Colors.indigo.shade600 : Colors.grey.shade600,
              ),
              tooltip: 'Invoices',
            ),
          ],
        ),
      ),
    );
  }
}