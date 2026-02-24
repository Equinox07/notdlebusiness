import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/screens/initial_setup_screen.dart';
import 'package:country_picker/country_picker.dart';

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
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedBusinessType;
  Country? _selectedCountry;
  bool _isLoading = false;

  final Color primaryPurple = const Color(0xFF6B11B2);
  final Color textGrey = const Color(0xFF64748B);
  final Color bgColor = const Color(0xFFF9F7F2);
  final Color inputBg = Colors.white;

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleNextStep() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushNamed(context, InitialSetupScreen.tag);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const SizedBox(height: 32),
                // Title
                Text(
                  'Your Business Profile',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  "Tell us about your craft to personalize your experience.",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: textGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                // Fields
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hintText';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedBusinessType,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.category_outlined,
            color: Colors.grey.shade400,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        hint: Text(
          'Select your craft',
          style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
        ),
        icon: Icon(Icons.keyboard_arrow_down, color: textGrey.withOpacity(0.5)),
        items:
            ['Tailor', 'Designer', 'Manufacturer', 'Boutique'].map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type, style: GoogleFonts.inter(fontSize: 14)),
              );
            }).toList(),
        onChanged: (value) => setState(() => _selectedBusinessType = value),
        validator:
            (value) => value == null ? 'Please select business type' : null,
      ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: inputBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.public_outlined, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedCountry?.name ?? 'Select Country',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color:
                      _selectedCountry == null
                          ? Colors.grey.shade400
                          : const Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
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
