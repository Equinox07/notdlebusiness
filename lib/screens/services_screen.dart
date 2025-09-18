// lib/screens/services_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/service_model.dart';
import 'package:notdle/screens/all_measurement_screen.dart';
// Your navigation destinations


class ServicesScreen extends StatelessWidget {
   const ServicesScreen({super.key});

  static const String tag = "services";

  final List<ServiceModel> _services =  const [
    ServiceModel(
      title: 'Customers',
      description: 'Manage clients profiles',
      icon: Icons.people_outline,
      iconColor: Colors.blue,
    ),
    ServiceModel(
      title: 'Measurements',
      description: 'Manage and update client measurements',
      icon: Icons.straighten,
      iconColor: Colors.orange,
    ),
    ServiceModel(
      title: 'Orders',
      description: 'Track progress and status of all orders',
      icon: Icons.shopping_bag_outlined,
      iconColor: Colors.green,
    ),
    ServiceModel(
      title: 'Designs',
      description: 'View and manage your design catalog',
      icon: Icons.palette_outlined,
      iconColor: Colors.purple,
    ),
    ServiceModel(
      title: 'Repairs',
      description: 'Log and track clothing repair jobs',
      icon: Icons.handyman_outlined,
      iconColor: Colors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Services",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: _services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            childAspectRatio: isTablet ? 1.0 : 0.9,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final service = _services[index];
            return _ServiceCard(
              service: service,
              onTap: () {
                // Handle navigation based on service type
                switch (service.title) {
                  case 'Customers':
                    debugPrint("Service clickd ${service.title}");

                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen()));
                    break;
                  case 'Measurements':
                    debugPrint("Service clickd ${service.title}");

                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AllMeasurementScreen()));
                    break;
                  case 'Orders':
                    debugPrint("Service clickd ${service.title}");

                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
                    break;

                  case 'Designs':
                    debugPrint("Service clickd ${service.title}");

                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const DesignsScreen()));
                    break;
                  case 'Repairs':
                    debugPrint("Service clickd ${service.title}");

                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const RepairsScreen()));
                    break;
                }
              },
            );
          },
        ),
      ),
    );
  }
}


class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Icon with a colored background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: service.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  service.icon,
                  size: 36,
                  color: service.iconColor,
                ),
              ),
              const SizedBox(height: 16),
              // Title and subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // ➡️ Apply overflow to the description text
                  Text(
                    service.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1, // Limit to two lines
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}