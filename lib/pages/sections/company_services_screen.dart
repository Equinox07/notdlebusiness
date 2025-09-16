// lib/screens/services_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/service_model.dart';

class CompanyServicesScreen extends StatelessWidget {
  CompanyServicesScreen({super.key});

  static String tag = "company_services";

  final List<ServiceModel> _services = [
    ServiceModel(
      title: 'Fashion Design',
      description: 'Create custom outfits and apparel for any occasion.',
      icon: Icons.checkroom,
      iconColor: Colors.purple,
    ),
    ServiceModel(
      title: 'Bespoke Tailoring',
      description: 'Expert tailoring and alterations for a perfect fit.',
      icon: Icons.cut,
      iconColor: Colors.blue,
    ),
    ServiceModel(
      title: 'Styling Consultancy',
      description: 'Professional advice to define and refine your personal style.',
      icon: Icons.style,
      iconColor: Colors.orange,
    ),
    ServiceModel(
      title: 'Bridal & Occasion Wear',
      description: 'Specialized design for weddings, proms, and events.',
      icon: Icons.diamond,
      iconColor: Colors.pink,
    ),
    ServiceModel(
      title: 'Material Sourcing',
      description: 'Find and select the finest fabrics and materials.',
      icon: Icons.palette,
      iconColor: Colors.brown,
    ),
    ServiceModel(
      title: 'Garment Repair',
      description: 'Mending and restoration of damaged clothing.',
      icon: Icons.handyman,
      iconColor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Our Services',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _ServiceCard(service: service),
          );
        },
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const _ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: service.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service.icon,
                size: 32,
                color: service.iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}