// lib/screens/company_registration_screen.dart

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:notdle/screens/login_page_screen.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CompanyRegistrationScreen extends StatefulWidget {
  const CompanyRegistrationScreen({super.key});

  static const String tag = "company_register";

  @override
  State<CompanyRegistrationScreen> createState() =>
      _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState extends State<CompanyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _countryCodeController = TextEditingController();
  String? _selectedCountryCode;

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    _businessNameController.dispose();
    _yearsOfExperienceController.dispose();
    _registrationNumberController.dispose();
    _addressController.dispose();
    _countryCodeController.dispose();
    super.dispose();
  }

  Future<void> _registerCompany() async {
    if (_formKey.currentState!.validate()) {
      // ➡️ Perform the pre-check
      // final bool exists = await _dbHelper.companyExists(
      //   _emailController.text,
      //   _mobileController.text,
      // );
      //
      // if (exists) {
      //   // ➡️ Show alert dialog if company already exists
      //   _showLoginDialog();
      //   return;
      // }

      final newCompany = Company(
        id: Uuid().v4(),
        fullName: '', // Full name is no longer collected
        email: _emailController.text,
        mobile: _mobileController.text,
        businessName: _businessNameController.text,
        yearsOfExperience: int.parse(_yearsOfExperienceController.text),
        registrationNumber: _registrationNumberController.text,
        address: _addressController.text,
        countryCode: _selectedCountryCode!,
      );

      // ➡️ Await the returned company object after insertion
      // final registeredCompany = await _dbHelper.registerCompany(newCompany);

      final registeredCompany = await Provider.of<CompanyProvider>(context, listen: false)
          .registerCompany(newCompany);


      debugPrint("Saved company $registeredCompany");

      //Persist data to shared preferences
      await SessionManager.saveCompany(registeredCompany!);

      if(mounted){
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registration successful!')));
      }

      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => const DashboardAppScreen()),
      // );

      AppNavigator.toHome2();
    }
  }

  // ➡️ New method to show the alert dialog
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account Already Exists'),
          content: const Text(
            'The provided email or mobile number is already registered. Please log in.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginPageScreen(),
                  ),
                );
              },
              child: const Text('Go to Login'),
            ),
          ],
        );
      },
    );
  }

  // lib/screens/company_registration_screen.dart

  // ... (other code)

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    // Add the validator parameter
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade200,
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

  // Widget _buildInputField({
  //   required String label,
  //   required TextEditingController controller,
  //   TextInputType keyboardType = TextInputType.text,
  //   bool isRequired = true,
  //   int maxLines = 1,
  // }) {
  //   return TextFormField(
  //     controller: controller,
  //     keyboardType: keyboardType,
  //     maxLines: maxLines,
  //     decoration: InputDecoration(
  //       labelText: label,
  //       labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
  //       filled: true,
  //       fillColor: Colors.grey.shade200,
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: BorderSide.none,
  //       ),
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: BorderSide.none,
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: BorderSide(color: Colors.indigo.shade600, width: 2),
  //       ),
  //     ),
  //     validator: (value) {
  //       if (isRequired && (value == null || value.isEmpty)) {
  //         return 'This field is required.';
  //       }
  //       return null;
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back button
        title: Text(
          'Company Registration',
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
                  fontSize: 28,
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
              ),
              const SizedBox(height: 16),
              // _buildInputField(
              //   label: "Mobile Number",
              //   controller: _mobileController,
              //   keyboardType: TextInputType.phone,
              // ),
              // Mobile number and country code in a single row
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CountryCodePicker(
                      onChanged: (CountryCode code) {
                        setState(() {
                          _selectedCountryCode = code.code!;
                        });
                      },
                      initialSelection: 'US',
                      favorite: const ['+233', 'US', '+91'],
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
                label: "Years of Experience",
                controller: _yearsOfExperienceController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: "Registration Number",
                controller: _registrationNumberController,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: "Address",
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
    );
  }
}
