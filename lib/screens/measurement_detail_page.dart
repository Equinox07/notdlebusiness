//MeasurementDetailPage
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/screens/add_measurement_screen.dart';
import 'package:notdle/screens/customer_measurement.dart';

// Assuming your Customer and Measurement models are correctly defined.

class MeasurementDetailPage extends StatelessWidget {
  final Measurement measurement;
  static const String tag = "measurement_details";

  const MeasurementDetailPage({super.key, required this.measurement});

  @override
  Widget build(BuildContext context) {
    final customer = measurement.customer!;
    final isTablet = MediaQuery.of(context).size.width > 600;

    final femaleFields = {
      "Bust": "Bust",
      "Niple to Niple": "Niple to Niple",
      "Under Bust": "Under Bust",
      "Waist": "Waist",
      "Shoulder to Shoulder": "Shoulder to Shoulder",
      "Full Blouse Length": "Full Blouse Length",
      "Across Back": "Across Back",
      "Around Arm": "Around Arm",
      "Sleeve Length": "Sleeve Length",
      "Sleeve Measurement": "Sleeve Measurement",
      "Trouser Waist": "Trouser Waist",
      "Thigh": "Thigh",
      "Hip": "Hip",
      "Knee": "Knee",
      "Base": "Base",
      "Cloth Type": "Cloth Type",
    };

    final maleFields = {
      "Chest": "Chest",
      "Across Back": "Across Back",
      "Sleeve": "Sleeve",
      "Cuff": "Cuff",
      "Shirt": "Shirt",
      "Waist": "Waist",
      "Thigh": "Thigh",
      "Knee": "Knee",
      "Base": "Base",
      "Trouser": "Trouser",
      "Chin": "Chin",
    };

    final fields =
        customer.gender.toLowerCase() == "female" ? femaleFields : maleFields;
    final displayFields = measurement.measurementValues.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Measurements",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Fixed Customer Header
          _CustomerHeader(customer: customer),

          // Scrollable Measurements Grid
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isTablet ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children:
                      displayFields.map((field) {
                        String label = fields[field] ?? field;
                        String valueText;
                        if (field == "Sleeve Length" &&
                            customer.gender.toLowerCase() == "female") {
                          final sleeveOptions = [
                            "None",
                            "Short",
                            "3 Quarters",
                            "Full",
                          ];
                          final index =
                              measurement.measurementValues[field]?.toInt() ??
                              0;
                          valueText = sleeveOptions[index];
                        } else if (field == "Cloth Type" &&
                            customer.gender.toLowerCase() == "female") {
                          final clothOptions = [
                            "None",
                            "Trouser",
                            "Skirt",
                            "Full Dress",
                          ];
                          final index =
                              measurement.measurementValues[field]?.toInt() ??
                              0;
                          final val =
                              measurement.measurementValues["Cloth"] ?? 0.0;
                          valueText = "${clothOptions[index]}: $val";
                        } else {
                          final val = measurement.measurementValues[field];
                          valueText =
                              val != null ? val.toStringAsFixed(1) : "N/A";
                        }

                        return _MeasurementCard(label: label, value: valueText);
                      }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerMeasurementScreen(customer: customer),
            ),
          );
        },
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Add New",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: const SizedBox(height: 70),
    );
  }
}

class _CustomerHeader extends StatelessWidget {
  final dynamic customer;

  const _CustomerHeader({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.indigo.shade100,
            backgroundImage:
                customer.imagePath != null
                    ? FileImage(File(customer.imagePath!))
                    : null,
            child:
                customer.imagePath == null
                    ? Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : "?",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    )
                    : null,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${customer.gender} • ${customer.phone}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final String label;
  final String value;

  const _MeasurementCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
