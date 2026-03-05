import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/dashboard_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:notdle/widgets/custom_app_bar.dart';
import 'package:uuid/uuid.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  static const String tag = "add_customer";

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Info
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedGender = "Female"; // Default
  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF6200EE),
                  ),
                  title: Text(
                    "Take a photo",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF6200EE),
                  ),
                  title: Text(
                    "Choose from gallery",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _save(bool withMeasurements) async {
    if (!_formKey.currentState!.validate()) return;

    final customerId = const Uuid().v4();
    final now = DateTime.now();

    final newCustomer = Customer(
      id: customerId,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email:
          _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
      address:
          _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
      lastVisit: now,
      gender: _selectedGender,
      imagePath: _imagePath,
      createdDate: now,
    );

    debugPrint("New Customer: $newCustomer");
    // Save Customer
    await Provider.of<CustomerProvider>(
      context,
      listen: false,
    ).addNewCustomer(newCustomer);

    if (mounted) {
      Provider.of<DashBoardProvider>(context, listen: false).fetchCounts();
      if (withMeasurements) {
        AppNavigator.toNewMeasurement(newCustomer);
      } else {
        Navigator.pop(context, newCustomer);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: CustomAppBar(
        title: "Add New Client",
        centerTitle: true,
        isLight: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Color(0xFF6200EE)),
        ),
        actions: [
          TextButton(
            onPressed: () => _save(false),
            child: Text(
              "Save",
              style: GoogleFonts.poppins(
                color: const Color(0xFF6200EE),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ), // unified padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFFF3E8FF),
                              backgroundImage:
                                  _imagePath != null
                                      ? FileImage(File(_imagePath!))
                                      : null,
                              child:
                                  _imagePath == null
                                      ? const Icon(
                                        Icons.person_add_rounded,
                                        size: 40,
                                        color: Color(0xFF6200EE),
                                      )
                                      : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6200EE),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(Icons.person, "PERSONAL INFORMATION"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: "Full Name",
                controller: _nameController,
                hintText: "Sarah Jenkins",
                validator:
                    (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: "Mobile Number",
                      controller: _phoneController,
                      hintText: "5550000000",
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Required";
                        if (val.length != 10) return "Must be 10 digits";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdownField(
                      label: "Gender",
                      value: _selectedGender,
                      items: ["Female", "Male", "Other"],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedGender = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInputField(
                label: "Email Address (Optional)",
                controller: _emailController,
                hintText: "sarah.j@example.com",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                label: "Address",
                controller: _addressController,
                hintText: "123 Main St, City, Country",
                keyboardType: TextInputType.streetAddress,
                validator:
                    (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 80), // Keep some spacing for bottom sheet
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomButtons(),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6200EE)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5C6280),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6200EE)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF6200EE),
                width: 1.5,
              ),
            ),
          ),
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          validator: validator,
          cursorColor: const Color(0xFF6200EE),
          decoration: InputDecoration(
            hintText: hintText,
            counterText: "", // Hide character counter
            hintStyle: GoogleFonts.poppins(color: Colors.black26),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14, // slightly tighter
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ), // faint border
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ), // faint border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF6200EE),
                width: 1.5,
              ),
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), // unified padding
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF0F0F0)),
        ), // faint border
      ),
      child: GestureDetector(
        onTap: () => _save(true),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16), // tighter
          decoration: BoxDecoration(
            color: const Color(0xFF6200EE),
            borderRadius: BorderRadius.circular(20), // smooth radius
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6200EE).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            "Save & Take Measurements",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
