import 'package:flutter/material.dart';
import 'package:notdle/screens/customers_screen.dart';
import 'package:notdle/screens/invoices_screen.dart';
import 'package:notdle/screens/orders_screen.dart';
import 'package:notdle/screens/services_screen.dart';
import 'package:notdle/pages/dashboards/dashboard_home.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo.shade600,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        elevation: 8,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Clients",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services), // _ServiceBottomNavItem(isSelected: _selectedIndex == 2),
            label: "Services",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Orders",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: "Invoices",
          ),
        ],
      ),
    );
  }
}


class _ServiceBottomNavItem extends StatelessWidget {
  final bool isSelected;
  const _ServiceBottomNavItem({
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.design_services,
          color: isSelected ? Colors.indigo.shade600 : Colors.grey.shade600,
          size: isSelected ? 30 : 24, // ✅ Larger icon for emphasis
        ),
        Text(
          "Services",
          style: TextStyle(
            fontSize: isSelected ? 12 : 10,
            color: isSelected ? Colors.indigo.shade600 : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}