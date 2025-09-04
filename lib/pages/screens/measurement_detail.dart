import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/measurement.dart';

class MeasurementDetailScreen extends StatelessWidget {
  final Measurement measurement;
  // final customer = measurement.customer; // linked customer
  // final Customer customer;

  const MeasurementDetailScreen({
    super.key,
    required this.measurement,
    // required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final customer = measurement.customer; // linked customer
    final isTablet = MediaQuery.of(context).size.width > 600;
    final femaleFields = [
      "Bust",
      "Niple to Niple",
      "Under Bust",
      "Waist",
      "Shoulder to Shoulder",
      "Full Blouse Length",
      "Across Back",
      "Around Arm",
      "Sleeve Length/Short/3 Quarters/Full",
      "Trouser Waist",
      "Thigh",
      "Hip",
      "Knee",
      "Base",
      "Cloth",
    ];

    final maleFields = [
      "Chest",
      "Across Back",
      "Sleeve",
      "Cuff",
      "Shirt",
      "Waist",
      "Thigh",
      "Knee",
      "Base",
      "Trouser",
      "Chin",
    ];

    final fields =
        customer!.gender.toLowerCase() == "female" ? femaleFields : maleFields;

    final sleeveOptions = ["Short", "3 Quarters", "Full"];
    final clothOptions = ["Trouser", "Skirt", "Full Dress"];

    Widget buildField(String field) {
      if (field == "Sleeve Length/Short/3 Quarters/Full" &&
          customer.gender.toLowerCase() == "female") {
        final index = measurement.measurementValues["SleeveLength"]?.toInt() ?? 0;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            "Sleeve Length: ${sleeveOptions[index]}",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      if (field == "Cloth" && customer.gender.toLowerCase() == "female") {
        final index = measurement.measurementValues["ClothType"]?.toInt() ?? 0;
        final val = measurement.measurementValues["Cloth"] ?? 0.0;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            "Cloth (${clothOptions[index]}): $val",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      final value = measurement.measurementValues[field] ?? 0.0;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          "$field: $value",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "${customer.gender} • ${customer.phone}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: fields.length,
        itemBuilder: (context, index) => buildField(fields[index]),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
      ),
    );
  }
}
