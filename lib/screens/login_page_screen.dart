// lib/screens/login_screen.dart
//LoginPageScreen
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/screens/company_registration_screen.dart';
import 'package:notdle/screens/signup_screen.dart';
import 'package:notdle/services/api_service.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:notdle/utils/helpers.dart';

class LoginPageScreen extends StatefulWidget {
  const LoginPageScreen({super.key});

  static const String tag = "login_page";

  @override
  State<LoginPageScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Make text white for better visibility on dark background
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required.';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<void> login() async {
      if (!_formKey.currentState!.validate()) return;

      try {
        // Show loading indicator
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(child: CircularProgressIndicator());
            },
          );
        }

        // Get device IMEI (optional)
        String? deviceImei = await getDeviceImei();
        
        // If IMEI is null or empty, fallback to device ID
        if (deviceImei == null || deviceImei.isEmpty) {
          deviceImei = await getDeviceId();
        }

        // Perform login
        final data = await _apiService.login(
          _emailController.text,
          _passwordController.text,
          deviceImei: deviceImei,
        );

        // Get fresh user data from the server
        await _apiService.getCurrentUser();

        // Get stored user data
        final user = await _apiService.getStoredUser();

        if (user == null) {
          throw Exception('Failed to load user data');
        }

        // Check if user has a company and companyId is not null
        if (user.hasCompany && user.companyId != null) {
          try {
            // Fetch company data
            final companyData = await _apiService.getCompanyById(
              user.companyId!,
            );
            // final company = Company.fromMap(companyData);

            // Save company data to session
            await SessionManager.saveCompany(companyData);

            // Close loading dialog
            if (mounted) {
              Navigator.of(context).pop();
              // Navigate to dashboard
              Navigator.of(context).pushReplacementNamed('dashboard');
            }
          } catch (e) {
            // Close loading dialog
            if (mounted) {
              Navigator.of(context).pop();
              // Show error but still allow login (company data might not be critical)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Logged in, but failed to load company data: ${e.toString()}',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
              // Still navigate to dashboard even if company data fails
              Navigator.of(context).pushReplacementNamed('dashboard');
            }
          }
        } else {
          // Close loading dialog
          if (mounted) {
            Navigator.of(context).pop();
            // Navigate to company registration if no company
            Navigator.of(
              context,
            ).pushReplacementNamed(CompanyRegistrationScreen.tag);
          }
        }
      } catch (e) {
        // Close loading dialog if still open
        if (mounted) {
          Navigator.of(context).pop();
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final maxFormWidth = isTablet ? 500.0 : double.infinity;
    final horizontalPadding = isTablet ? 32.0 : 24.0;

    // Logo and App Name widget
    final logoWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/logo.png', width: isTablet ? 40 : 32),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notdle',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Precision in every stitch',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 12 : 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: logoWidget,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/us_flag.png',
                  width: isTablet ? 36 : 30,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/splash_screen.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Semi-transparent overlay
            Container(color: Colors.black.withOpacity(0.5)),
            // Content
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxFormWidth),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          "Welcome back!",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Login to your account to continue.",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildInputField(
                          label: "Email",
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: "Password",
                          controller: _passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Login",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const SignupScreenPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Register",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
