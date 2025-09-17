// lib/screens/add_customer_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/db/database_helper.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:provider/provider.dart';
import 'package:notdle/providers/dashboard_provider.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // For File

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  static const String tag = "add_customer";

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedGender;
  File? _profileImage; // Stores the selected image file

  final ImagePicker _picker = ImagePicker(); // Image picker instance

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<Customer?> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return null;

    if (_selectedGender == null || _selectedGender == "Other") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a valid gender.",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    final newCustomer = Customer(
      name: _nameController.text.trim(),
      gender: _selectedGender!,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      lastVisit: DateTime.now(),
      createdDate: DateTime.now(),
      imagePath: _profileImage?.path, // Save image path if available
    );

    // final savedCustomer = await DatabaseHelper.instance.insertCustomer(
    //   newCustomer,
    // );
    final savedCustomer = await Provider.of<CustomerProvider>(context, listen: false)
        .addNewCustomer(newCustomer);

    if(mounted){
      Provider.of<DashBoardProvider>(context, listen: false).fetchCounts();
    }

    return savedCustomer;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard on tap outside
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50, // Lighter background
        appBar: AppBar(
          title: Text(
            "Add New Customer",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0, // Flat app bar for modern look
          iconTheme: const IconThemeData(color: Colors.black87),
          actions: [
            TextButton(
              onPressed: () async {
                final saved = await _saveCustomer();
                if (saved != null) {
                  Navigator.pop(context, saved);
                }
              },
              child: Text(
                "Save",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade600,
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              // Image Picker Area
              Center(
                child: GestureDetector(
                  onTap: _pickImage, // Make the image area clickable
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.indigo.shade100,
                        backgroundImage:
                        _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                            ? Icon(
                          Icons.camera_alt_outlined,
                          size: 50,
                          color: Colors.indigo.shade600,
                        )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.indigo.shade600,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.indigo.shade600,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              _buildTextFormField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _phoneController,
                label: "Phone Number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Enter phone number";
                  }
                  if (val.length != 10) {
                    return "Phone number must be 10 digits";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _emailController,
                label: "Email Address",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Enter email";
                  }
                  if (!val.contains("@") || !val.contains(".")) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildGenderDropdown(),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _addressController,
                label: "Address",
                icon: Icons.location_on_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomActionButton(),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: Colors.indigo.shade600, size: 24),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // More rounded corners
          borderSide: BorderSide.none, // No default border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.indigo.shade600, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        counterText: "", // Hide character counter for phone number
      ),
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
      cursorColor: Colors.indigo.shade600,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: "Gender",
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(Icons.transgender, color: Colors.indigo.shade600, size: 24),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.indigo.shade600, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
      items: ["Male", "Female"].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue;
        });
      },
      validator: (val) => val == null ? "Select gender" : null,
      dropdownColor: Colors.white, // Ensure dropdown items are visible
      icon: Icon(Icons.arrow_drop_down, color: Colors.indigo.shade600),
      isExpanded: true,
    );
  }

  Widget _buildBottomActionButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), // Rounded top for bottom bar
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final saved = await _saveCustomer();
            if (saved != null) {
              // TODO: AppNavigator.toMeasurement2(customer: saved);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade600, // Primary action color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            elevation: 5,
          ),
          icon: const Icon(Icons.straighten, color: Colors.white, size: 24),
          label: Text(
            "Save & Take Measurement",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}