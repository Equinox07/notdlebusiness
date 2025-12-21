// lib/screens/services_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/service_model.dart';
import 'package:notdle/screens/all_measurement_screen.dart';
import 'package:notdle/widgets/custom_app_bar.dart';
// Your navigation destinations

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const String tag = "services";

  final List<ServiceModel> _services = const [
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
      appBar: const CustomAppBar(title: "Services"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          itemCount: _services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemBuilder: (context, index) {
            final service = _services[index];
            return _ServiceCard(
              service: service,
              onTap: () {
                switch (service.title) {
                  case 'Customers':
                    debugPrint("Service clicked ${service.title}");
                    break;
                  case 'Measurements':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllMeasurementScreen(),
                      ),
                    );
                    break;
                  case 'Orders':
                    debugPrint("Service clicked ${service.title}");
                    break;
                  case 'Designs':
                    debugPrint("Service clicked ${service.title}");
                    break;
                  case 'Repairs':
                    debugPrint("Service clicked ${service.title}");
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

  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: service.iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(service.icon, size: 32, color: service.iconColor),
                ),
                const Spacer(),
                Text(
                  service.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  service.description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
