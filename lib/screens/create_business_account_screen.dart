import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/screens/initial_setup_screen.dart';
import 'package:country_picker/country_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/providers/api_provider.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:notdle/utils/helpers.dart';
import 'package:notdle/pages/dashboards/dashboard_screen.dart';

class CreateBusinessAccountScreen extends StatefulWidget {
  static const String tag = 'create-business-account';

  const CreateBusinessAccountScreen({super.key});

  @override
  State<CreateBusinessAccountScreen> createState() =>
      _CreateBusinessAccountScreenState();
}

class _CreateBusinessAccountScreenState
    extends State<CreateBusinessAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedBusinessType;
  Country? _selectedCountry;
  String? _selectedCountryCode;
  bool _isLoading = false;
  bool _isPhoneNull = false;

  final Color primaryPurple = const Color(0xFF6B11B2);
  final Color textGrey = const Color(0xFF64748B);
  final Color bgColor = const Color(0xFFF9F7F2);
  final Color inputBg = Colors.grey.shade200;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    final user = await apiProvider.apiService.getStoredUser();
    if (user != null) {
      setState(() {
        _emailController.text = user.email;

        if (user.phone == null || user.phone!.isEmpty) {
          _isPhoneNull = true;
          _selectedCountryCode = '+1'; // default
        } else {
          _isPhoneNull = false;
          // User model uses 'phone', let's check if it needs parsing for country code
          if (user.phone!.startsWith('+')) {
            // Rudimentary split for prepopulation if needed,
            // but for now just putting the whole thing or last 10 digits
            if (user.phone!.length > 10) {
              _mobileController.text = user.phone!.substring(
                user.phone!.length - 10,
              );
              _selectedCountryCode = user.phone!.substring(
                0,
                user.phone!.length - 10,
              );
            } else {
              _mobileController.text = user.phone!;
            }
          } else {
            _mobileController.text = user.phone!;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleNextStep() async {
    if (_formKey.currentState!.validate()) {
      await _registerCompany();
    }
  }

  Future<void> _registerCompany() async {
    if (!mounted) return;

    try {
      context.loaderOverlay.show();
      await _registerCompanyProcess();
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) context.loaderOverlay.hide();
    }
  }

  void _handleError(dynamic error) {
    if (!mounted) return;
    final errorMessage = 'Error: ${error.toString()}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  Future<void> _registerCompanyProcess() async {
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    final companyProvider = Provider.of<CompanyProvider>(
      context,
      listen: false,
    );

    // Determine currency based on country code
    String currency = 'USD'; // Default to USD
    if (_selectedCountryCode == '+233') {
      currency = 'GHS';
    } else if (_selectedCountryCode == '+234') {
      currency = 'NGN';
    } else if (_selectedCountryCode == '+44') {
      currency = 'GBP';
    } else if (_selectedCountryCode == '+91') {
      currency = 'INR';
    }

    // Map business type to API enum
    String apiBusinessType = 'OTHER';
    if (_selectedBusinessType == 'Tailor' ||
        _selectedBusinessType == 'Designer') {
      apiBusinessType = 'SERVICE';
    } else if (_selectedBusinessType == 'Manufacturer') {
      apiBusinessType = 'MANUFACTURING';
    } else if (_selectedBusinessType == 'Boutique') {
      apiBusinessType = 'RETAIL';
    }

    final String deviceId = await getDeviceId();

    final companyData = {
      'businessName': _businessNameController.text.trim(),
      'email': _emailController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'address':
          '${_addressController.text.trim()}, ${_locationController.text.trim()}',
      'countryCode': _selectedCountryCode ?? '+1',
      'currency': currency,
      'country': _selectedCountry?.name ?? 'United States',
      'businessType': apiBusinessType,
      'deviceId': deviceId,
      'yearsOfExperience': 0, // Default to 0
      'registrationNumber': 'na', // Default to na
      'locationName': _locationController.text.trim(),
      'enablePushNotifications': false,
      'enableSmsNotifications': false,
      'enableEmailNotifications': false,
      'measurementSystem': null,
      'appAppearance': null,
      'genderSpecialty': null,
    };

    try {
      final response = await apiProvider.apiService.registerCompany(
        companyData,
      );
      final registeredCompany = Company.fromMap(response);

      await SessionManager.saveCompany(registeredCompany);
      await companyProvider.registerCompany(registeredCompany);
      await apiProvider.apiService.getCurrentUser();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company registered successfully!')),
      );

      Navigator.pushNamed(context, InitialSetupScreen.tag);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E0FF).withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: primaryPurple,
                            size: 20,
                          ),
                        ),
                      ),
                      Text(
                        'STEP 2 OF 3',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textGrey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Title
                  Text(
                    'Your Business Profile',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    "Tell us about your craft to personalize your experience.",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: textGrey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Fields
                  if (_isPhoneNull) ...[
                    _buildFieldLabel('MOBILE NUMBER'),
                    _buildPhoneField(),
                    const SizedBox(height: 24),
                  ],
                  _buildFieldLabel('BUSINESS NAME'),
                  _buildTextField(
                    controller: _businessNameController,
                    hintText: 'e.g. Elite Tailoring',
                    icon: Icons.storefront_outlined,
                  ),
                  const SizedBox(height: 24),
                  _buildFieldLabel('BUSINESS TYPE'),
                  _buildDropdownField(),
                  const SizedBox(height: 24),
                  _buildFieldLabel('PHYSICAL ADDRESS'),
                  _buildTextField(
                    controller: _addressController,
                    hintText: 'e.g. 123 Fashion Ave',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 24),
                  _buildFieldLabel('CITY / TOWN'),
                  _buildTextField(
                    controller: _locationController,
                    hintText: 'e.g. New York',
                    icon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 24),
                  _buildFieldLabel('COUNTRY'),
                  _buildCountrySelector(),
                  const SizedBox(height: 48),
                  // Next Step Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleNextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: primaryPurple.withOpacity(0.4),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Next Step',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textGrey.withOpacity(0.8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _mobileController,
      keyboardType: TextInputType.phone,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: 'e.g. 555 123 4567',
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
        filled: true,
        fillColor: inputBg,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                onSelect: (Country country) {
                  setState(() {
                    _selectedCountryCode = '+${country.phoneCode}';
                  });
                },
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedCountryCode ?? '+1',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade600,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.indigo),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
          ),
        ),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter mobile number';
        }
        if (value.length != 10) {
          return 'Mobile number must be 10 digits';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
        filled: true,
        fillColor: inputBg,
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $hintText';
            }
            return null;
          },
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedBusinessType,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: inputBg,
        prefixIcon: Icon(
          Icons.category_outlined,
          color: Colors.grey.shade400,
          size: 20,
        ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      hint: Text(
        'Select your craft',
        style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14),
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: textGrey.withOpacity(0.5)),
      items:
          ['Tailor', 'Designer', 'Manufacturer', 'Boutique'].map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type, style: GoogleFonts.poppins(fontSize: 14)),
            );
          }).toList(),
      onChanged: (value) => setState(() => _selectedBusinessType = value),
      validator:
          (value) => value == null ? 'Please select business type' : null,
    );
  }

  Widget _buildCountrySelector() {
    return GestureDetector(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: false,
          onSelect: (Country country) {
            setState(() {
              _selectedCountry = country;
            });
          },
          countryListTheme: CountryListThemeData(
            borderRadius: BorderRadius.circular(16),
            inputDecoration: InputDecoration(
              hintText: 'Search country',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
        );
      },
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: inputBg,
          prefixIcon: Icon(
            Icons.public_outlined,
            color: Colors.grey.shade400,
            size: 20,
          ),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedCountry?.name ?? 'Select Country',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color:
                      _selectedCountry == null
                          ? Colors.grey.shade600
                          : Colors.black87,
                  fontWeight:
                      _selectedCountry == null
                          ? FontWeight.normal
                          : FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: textGrey.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
