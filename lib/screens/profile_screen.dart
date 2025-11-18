// lib/screens/profile_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String tag = "profile_screen";

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Company?> _companyFuture;
  final ImagePicker _picker = ImagePicker();
  // final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _companyFuture = SessionManager.getCompany();
  }


  // Method to handle picking an image from the gallery
  Future<void> _pickImage(Company company) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Save the new image path to the database
      // await _dbHelper.updateCompanyImagePath(company.id!, pickedFile.path);
      final companyProvider = Provider.of<CompanyProvider>(context, listen: false);

      final updatedCompany = company.copyWith(
          imagePath: pickedFile.path
      );

      await companyProvider.update(updatedCompany);


      // Update shared preferences with the new path
      // final updatedCompany = company.copyWith(imagePath: pickedFile.path);
      await SessionManager.saveCompany(updatedCompany);

      // Refresh the UI to display the new image
      setState(() {
        _companyFuture = Future.value(updatedCompany);
      });
    }
  }

  @override
  Widget build(BuildContext context) {





    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: FutureBuilder<Company?>(
        future: _companyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: GoogleFonts.poppins(),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                "No company data found. Please log in.",
                style: GoogleFonts.poppins(),
              ),
            );
          }

          final company = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileHeader(company),
                  const SizedBox(height: 16),
                  _buildDetailsCard(company),
                  const SizedBox(height: 16),
                  _buildLogoutButton(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // A helper method to build the profile header
  Widget _buildProfileHeader(Company company) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Stack(
              children: [
                // Display the image or a default icon
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.indigo,
                  backgroundImage: company.imagePath != null
                      ? FileImage(File(company.imagePath!)) as ImageProvider
                      : null,
                  child: company.imagePath == null
                      ? const Icon(Icons.business, size: 50, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _pickImage(company),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.indigo.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              company.businessName,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              company.fullName,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A helper method to build the company details card
  Widget _buildDetailsCard(Company company) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(
              icon: Icons.email,
              label: 'Email',
              value: company.email,
            ),
            const Divider(),
            _buildDetailRow(
              icon: Icons.phone,
              label: 'Mobile',
              value: '${company.countryCode} ${company.mobile}',
            ),
            const Divider(),
            _buildDetailRow(
              icon: Icons.business_outlined,
              label: 'Registration No',
              value: company.registrationNumber,
            ),
            const Divider(),
            _buildDetailRow(
              icon: Icons.work_outline,
              label: 'Experience',
              value: '${company.yearsOfExperience} years',
            ),
            const Divider(),
            _buildDetailRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: company.address,
            ),
          ],
        ),
      ),
    );
  }

  // A helper method for individual detail rows
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // A helper method for the logout button
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          "Logout",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          // TODO: Implement logout logic
        },
      ),
    );
  }
}