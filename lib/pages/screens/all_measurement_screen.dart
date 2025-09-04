import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/db/database_helper.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/pages/screens/measurement_detail.dart';

class AllMeasurementScreen extends StatefulWidget {
  const AllMeasurementScreen({super.key});

  static const String tag = "all_measurement";

  @override
  State<AllMeasurementScreen> createState() => _AllMeasurementScreenState();
}

class _AllMeasurementScreenState extends State<AllMeasurementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Measurement> measurements = [];
  List<Measurement> filteredMeasurements = [];

  @override
  void initState() {
    super.initState();
    _fetchMeasurements();
    _searchController.addListener(_filterMeasurements);
  }

  Future<void> _fetchMeasurements() async {
    final list =
        await DatabaseHelper.instance
            .fetchAllMeasurementsWithCustomer(); // returns List<Measurement>
    setState(() {
      measurements = list;
      filteredMeasurements = list;
    });
  }

  void _filterMeasurements() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredMeasurements =
          measurements.where((m) {
            final customer = m.customer; // assuming you fetch linked customer
            return customer!.name.toLowerCase().contains(query) ||
                customer.phone.contains(query) ||
                customer.email!.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'All Measurements',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search measurements...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // Count
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              '${filteredMeasurements.length} measurements found',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),

          // Measurement list
          Expanded(
            child:
                filteredMeasurements.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.straighten,
                            size: isTablet ? 80 : 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: isTablet ? 20 : 16),
                          Text(
                            'No measurements found',
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      itemCount: filteredMeasurements.length,
                      itemBuilder: (context, index) {
                        final measurement = filteredMeasurements[index];
                        final customer = measurement.customer; // linked
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => MeasurementDetailScreen(
                                        measurement: measurement,
                                      ),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              radius: isTablet ? 30 : 25,
                              backgroundColor: Colors.indigo.shade100,
                              backgroundImage:
                                  customer!.imageUrl != null
                                      ? NetworkImage(customer.imageUrl!)
                                      : (customer.imagePath != null
                                          ? FileImage(File(customer.imagePath!))
                                              as ImageProvider
                                          : null),
                              child:
                                  (customer.imageUrl == null &&
                                          customer.imagePath == null)
                                      ? Icon(
                                        Icons.person,
                                        size: isTablet ? 30 : 25,
                                        color: Colors.indigo.shade600,
                                      )
                                      : null,
                            ),
                            title: Text(
                              customer.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Last updated: ${measurement.createdDate.toLocal().toString().split(" ")[0]}',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
