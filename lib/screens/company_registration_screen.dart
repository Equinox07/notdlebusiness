// lib/screens/company_registration_screen.dart

import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/pages/dashboards/dashboard_screen.dart';
import 'package:notdle/providers/api_provider.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class CompanyRegistrationScreen extends StatefulWidget {
  const CompanyRegistrationScreen({super.key});

  static const String tag = "company_register";

  @override
  State<CompanyRegistrationScreen> createState() =>
      _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState extends State<CompanyRegistrationScreen> {
  static const _loadingWidget = Center(child: CircularProgressIndicator());

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  String? _selectedCountryCode;
  String? _selectedCountry;

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    _businessNameController.dispose();
    _yearsOfExperienceController.dispose();
    _registrationNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _registerCompany() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    try {
      _showLoadingOverlay();
      await _registerCompanyProcess();
    } catch (e) {
      _handleError(e);
    } finally {
      _hideLoadingOverlay();
    }
  }

  void _showLoadingOverlay() {
    if (!mounted) return;
    context.loaderOverlay.show();
  }

  void _hideLoadingOverlay() {
    if (!mounted) return;
    context.loaderOverlay.hide();
  }

  void _handleError(dynamic error) {
    if (!mounted) return;

    final errorMessage = 'Error: ${error.toString()}';
    debugPrint('Registration Error: $errorMessage');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  Future<void> _registerCompanyProcess() async {
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);

    // Determine currency based on country code
    String currency = 'GHS'; // Default to GHS
    if (_selectedCountryCode == '+1') {
      currency = 'USD';
    } else if (_selectedCountryCode == '+44') {
      currency = 'GBP';
    } else if (_selectedCountryCode == '+233') {
      currency = 'GHS';
    } else if (_selectedCountryCode == '+234') {
      currency = 'NGN';
    } else if (_selectedCountryCode == '+91') {
      currency = 'INR';
    }

    // Create company data map for API
    final companyData = {
      'businessName': _businessNameController.text.trim(),
      'email': _emailController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'yearsOfExperience':
          int.tryParse(_yearsOfExperienceController.text.trim()) ?? 0,
      'registrationNumber':
          _registrationNumberController.text.trim().isEmpty
              ? "N/A"
              : _registrationNumberController.text.trim(),
      'address': _addressController.text.trim(),
      'countryCode': _selectedCountryCode,
      'currency': currency,
      'country': _selectedCountry ?? 'Ghana',
    };

    try {
      // Register company via API
      final response = await apiProvider.apiService.registerCompany(
        companyData,
      );

      // Map response to Company object
      final registeredCompany = Company.fromMap(response);

      debugPrint('Registered Company: $registeredCompany');

      // Save company to session
      await SessionManager.saveCompany(registeredCompany);

      // Refresh current user data to update hasCompany status
      await apiProvider.apiService.getCurrentUser();

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company registered successfully!')),
      );

      // Navigate to dashboard
      Navigator.of(context).pushReplacementNamed(DashboardScreen.tag);
    } catch (e) {
      debugPrint('Error registering company: $e');
      rethrow; // This will be caught in the calling method
    }
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    // Add the validator parameter
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade200,
        counterText: "", // Hide the character counter
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade600, width: 2),
        ),
      ),
      validator:
          validator ??
          (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'This field is required.';
            }
            return null;
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      useDefaultLoading: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false, // This removes the back button
          title: Text(
            'Business Registration',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.indigo,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tell us about your business.",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Fill in the details below to create your account.",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                _buildInputField(
                  label: "Email",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email address.';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CountryCodePicker(
                        onChanged: (CountryCode? code) {
                          if (code != null) {
                            setState(() {
                              _selectedCountryCode = code.dialCode;
                              _selectedCountry = code.name;
                              debugPrint('Selected country: ${code.name}');
                            });
                          }
                        },
                        onInit: (CountryCode? code) {
                          if (code != null) {
                            setState(() {
                              _selectedCountryCode = code.dialCode;
                              _selectedCountry = code.name;
                              debugPrint('Selected country: ${code.name}');
                            });
                          }
                        },
                        initialSelection: 'US',
                        favorite: const [
                          '+233',
                          'US',
                          '+91',
                          '+234',
                          '+44',
                          '+254',
                        ],
                        showCountryOnly: true,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        label: "Mobile Number",
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a mobile number.';
                          }
                          if (value.length != 10) {
                            return 'Mobile number must be 10 digits.';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter only digits.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: "Business Name",
                  controller: _businessNameController,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: "Years of Experience (Optional)",
                  controller: _yearsOfExperienceController,
                  keyboardType: TextInputType.number,
                  isRequired: false,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number.';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: "Registration Number (Optional)",
                  controller: _registrationNumberController,
                  isRequired: false,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: "Address or Location",
                  controller: _addressController,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerCompany,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.indigo.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Register",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
