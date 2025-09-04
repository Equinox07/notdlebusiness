//
// ----------------- SERVICES + NAVIGATION -----------------
//
import 'package:flutter/material.dart';
import 'package:notdle/pages/dashboard_screen.dart';
import 'package:notdle/pages/screens/all_measurement_screen.dart';
import 'package:notdle/pages/screens/customers_screen.dart';
import 'package:notdle/pages/screens/designs_screen.dart';
import 'package:notdle/pages/screens/orders_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    //  Customer newCustomer = Customer(
    //   name: "John Doe",
    //   phone: "+123456789",
    //   email: "john@email.com",
    //   orders: 0,
    //   lastVisit: DateTime.now(),
    //   gender: "Male",
    //   address: "Accra",
    //   createdDate: DateTime.now(), // 🔹 auto
    // );

    return Scaffold(
      appBar: AppBar(title: const Text("Services")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: isTablet ? 3 : 2,
          childAspectRatio: isTablet ? 1.2 : 1.1,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            HomeMenuCard(
              title: 'Customers',
              subtitle: 'Manage clients',
              icon: Icons.people_outline,
              color: Colors.blue.shade600,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomersScreen()),
                );
              },
            ),
            HomeMenuCard(
              title: 'Measurements',
              subtitle: 'Take & update',
              icon: Icons.straighten,
              color: Colors.orange.shade600,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AllMeasurementScreen(),
                  ),
                );
              },
            ),
            HomeMenuCard(
              title: 'Orders',
              subtitle: 'Track progress',
              icon: Icons.shopping_bag_outlined,
              color: Colors.green.shade600,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
              },
            ),
            HomeMenuCard(
              title: 'Designs',
              subtitle: 'Style catalog',
              icon: Icons.palette_outlined,
              color: Colors.purple.shade600,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DesignsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
