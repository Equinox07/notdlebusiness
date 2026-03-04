import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:notdle/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  static const String tag = "company_profile_screen";

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _regController;
  late TextEditingController _yearsController;
  late TextEditingController _addressController;
  late TextEditingController _instagramController;
  late TextEditingController _websiteController;

  String? _selectedSpecialization;
  Company? _company;
  bool _isLoading = true;

  final List<String> _specializations = [
    'Bridal Wear',
    'Evening Wear',
    'General Tailoring',
    'Suits & Formal',
    'Traditional Wear',
  ];

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    final company = await SessionManager.getCompany();
    setState(() {
      _company = company;
      _nameController = TextEditingController(text: company?.businessName);
      _regController = TextEditingController(text: company?.registrationNumber);
      _yearsController = TextEditingController(
        text: company?.yearsOfExperience?.toString(),
      );
      _addressController = TextEditingController(text: company?.address);
      _instagramController = TextEditingController(
        text: "instagram.com/stitchflow__studio",
      ); // Mock
      _websiteController = TextEditingController(
        text: "stitchflow.design",
      ); // Mock
      _selectedSpecialization = company?.genderSpecialty ?? 'Bridal Wear';
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regController.dispose();
    _yearsController.dispose();
    _addressController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && _company != null) {
      final updatedCompany = _company!.copyWith(imagePath: pickedFile.path);
      setState(() {
        _company = updatedCompany;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate() && _company != null) {
      final updatedCompany = _company!.copyWith(
        businessName: _nameController.text,
        registrationNumber: _regController.text,
        yearsOfExperience: int.tryParse(_yearsController.text),
        address: _addressController.text,
        genderSpecialty: _selectedSpecialization,
      );

      final companyProvider = Provider.of<CompanyProvider>(
        context,
        listen: false,
      );
      await companyProvider.update(updatedCompany);
      await SessionManager.saveCompany(updatedCompany);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: CustomAppBar(
        title: "Company Profile",
        centerTitle: true,
        isLight: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: "GENERAL INFORMATION",
                children: [
                  _buildLabelledField("Legal Business Name", _nameController),
                  const SizedBox(height: 12),
                  _buildLabelledField("Registration Number", _regController),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          "Specialization",
                          _selectedSpecialization,
                          _specializations,
                          (val) {
                            setState(() => _selectedSpecialization = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLabelledField(
                          "Years in Business",
                          _yearsController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "SOCIAL LINKS",
                children: [
                  _buildSocialField(
                    _instagramController,
                    const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF6200EE),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSocialField(
                    _websiteController,
                    const Icon(
                      Icons.language,
                      color: Color(0xFF6200EE),
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "BUSINESS LOCATION",
                children: [
                  _buildLabelledField(
                    "Studio Address",
                    _addressController,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 12),
                  _buildMapPreview(),
                ],
              ),
              const SizedBox(height: 20),
              _buildSaveButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFFF5F5F5),
                  backgroundImage:
                      _company?.imagePath != null
                          ? FileImage(File(_company!.imagePath!))
                          : null,
                  child:
                      _company?.imagePath == null
                          ? Text(
                            "LB",
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w300,
                            ),
                          )
                          : null,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6200EE),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _company?.businessName ?? "StitchFlow Studio",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            "Premium Fashion Management",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF6200EE),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3E5F5),
              foregroundColor: const Color(0xFF6200EE),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: Text(
              "Edit Business Logo",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Divider(color: Colors.grey.shade100, thickness: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabelledField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF2C3E50).withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF2C3E50).withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black45,
              ),
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialField(TextEditingController controller, Widget icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5),
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            "https://i.ibb.co/L5Tdz1L/map-preview.png", // Mock map image
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  height: 180,
                  width: double.infinity,
                  color: const Color(0xFFF3E5F5),
                  child: const Icon(
                    Icons.map,
                    size: 40,
                    color: Color(0xFF6200EE),
                  ),
                ),
          ),
          const Positioned(
            child: Icon(Icons.location_on, color: Color(0xFF6200EE), size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6200EE).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _saveChanges,
        icon: const Icon(Icons.save, color: Colors.white, size: 18),
        label: Text(
          "Save Changes",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6200EE),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
