import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/measurement_provider.dart';
import 'package:provider/provider.dart';
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

    await context.read<MeasurementProvider>().getAllMeasurementWithCustomer();
    // final allMeasurements = context.watch<MeasurementProvider>().measurements;
    setState(() {
      // measurements = allMeasurements;
      // filteredMeasurements = allMeasurements;
      _isLoading = false;
    });
  }

  // Future<void> _loadCustomers() async {
  //   // final data = context.read<CustomerProvider>().fetchCustomers(); //await DatabaseHelper.instance.fetchCustomers();
  //   final customerProvider = Provider.of<CustomerProvider>(
  //     context,
  //     listen: false,
  //   );
  //   await customerProvider.fetchCustomers();
  //   setState(() {
  //     customers = customerProvider.customers;
  //     filteredCustomers = customerProvider.customers;
  //     _isLoading = false;
  //   });
  // }

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
    final allmeasurements = context.watch<MeasurementProvider>().measurements;

    filteredMeasurements = allmeasurements;
    measurements = allmeasurements;

    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Measurements',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        centerTitle: false,
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
    final measurementName =
        measurement.name.isNotEmpty ? measurement.name : "Untitled Measurement";

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              () => AppNavigator.toMeasurementDetails(measurement: measurement),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: isTablet ? 30 : 25,
                    backgroundColor: Colors.indigo.shade50,
                    backgroundImage:
                        customer.imagePath != null
                            ? FileImage(File(customer.imagePath!))
                            : null,
                    child:
                        customer.imagePath == null
                            ? Icon(
                              Icons.person,
                              color: Colors.indigo.shade300,
                              size: isTablet ? 30 : 24,
                            )
                            : null,
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        measurementName,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Date and Arrow
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${_getMonth(date.month)} ${date.day}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }
}
