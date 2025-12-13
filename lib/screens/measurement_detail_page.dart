//MeasurementDetailPage
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/measurement.dart';
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
    final measurementName =
        measurement.name.isNotEmpty ? measurement.name : "Untitled Measurement";
    final date = measurement.createdDate;

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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Details",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section (Name & Date)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    measurementName,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Created on ${_formatDate(date)}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Customer Card
            _CustomerHeader(customer: customer),

            const SizedBox(height: 24),

            // Measurements Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 16),
                    child: Text(
                      "Measurements",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isTablet ? 3 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
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

                          return _MeasurementCard(
                            label: label,
                            value: valueText,
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
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
        elevation: 4,
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        label: Text(
          "Edit Measurements",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
}

class _CustomerHeader extends StatelessWidget {
  final dynamic customer;

  const _CustomerHeader({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.indigo.shade50,
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
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade400,
                        ),
                      )
                      : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Customer",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customer.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      customer.phone,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
