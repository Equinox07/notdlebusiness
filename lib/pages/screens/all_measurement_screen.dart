import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/db/database_helper.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/navigation/app_navigation.dart';
// Assume this exists

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMeasurements();
    _searchController.addListener(_filterMeasurements);
  }

  Future<void> _fetchMeasurements() async {
    setState(() {
      _isLoading = true;
    });
    final list =
        await DatabaseHelper.instance.fetchAllMeasurementsWithCustomer();
    setState(() {
      measurements = list;
      filteredMeasurements = list;
      _isLoading = false;
    });
  }

  void _filterMeasurements() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredMeasurements =
          measurements.where((m) {
            final customer = m.customer;
            if (customer == null) return false;
            return customer.name.toLowerCase().contains(query) ||
                customer.phone.contains(query);
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
          // Search bar and count
          _SearchBarAndCount(
            controller: _searchController,
            count: filteredMeasurements.length,
          ),

          // Measurement list or empty state
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredMeasurements.isEmpty
                    ? _EmptyState(isTablet: isTablet)
                    : _MeasurementList(
                      measurements: filteredMeasurements,
                      isTablet: isTablet,
                    ),
          ),
        ],
      ),
    );
  }
}

class _SearchBarAndCount extends StatelessWidget {
  final TextEditingController controller;
  final int count;

  const _SearchBarAndCount({required this.controller, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
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
          const SizedBox(height: 12),
          Text(
            '$count measurements found',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isTablet;

  const _EmptyState({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Center(
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
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 20 : 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementList extends StatelessWidget {
  final List<Measurement> measurements;
  final bool isTablet;

  const _MeasurementList({required this.measurements, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      itemCount: measurements.length,
      itemBuilder: (context, index) {
        final measurement = measurements[index];
        return _MeasurementCard(measurement: measurement, isTablet: isTablet);
      },
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final Measurement measurement;
  final bool isTablet;

  const _MeasurementCard({required this.measurement, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final customer = measurement.customer!;
    final date = measurement.createdDate;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      child: InkWell(
        onTap:
            () => AppNavigator.toMeasurementDetails(measurement: measurement),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: isTablet ? 30 : 25,
                backgroundColor: Colors.indigo.shade100,
                backgroundImage:
                    customer.imagePath != null
                        ? FileImage(File(customer.imagePath!)) as ImageProvider
                        : null,
                child:
                    customer.imagePath == null
                        ? Text(
                          customer.name.isNotEmpty
                              ? customer.name[0].toUpperCase()
                              : "?",
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade600,
                          ),
                        )
                        : null,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 18 : 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Last updated: ${date.toLocal().toString().split(" ")[0]}",
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
