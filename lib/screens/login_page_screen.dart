// lib/screens/login_screen.dart
//LoginPageScreen
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/db/database_helper.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/pages/dashboards/dashboard_app.dart';
import 'package:notdle/pages/dashboards/dashboard_screen.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:notdle/screens/company_registration_screen.dart';
import 'package:notdle/screens/main.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:provider/provider.dart';

class LoginPageScreen extends StatefulWidget {
  const LoginPageScreen({super.key});

  static const String tag = "login_page";

  @override
  State<LoginPageScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPageScreen> {
  final _formKey = GlobalKey<FormState>();
  // final _dbHelper = DatabaseHelper.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();



  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



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

    Future<void> _login() async {
      if (_formKey.currentState!.validate()) {
        // You'll need to implement a getCompanyByEmailAndPassword method in your DatabaseHelper
        // final company = await _dbHelper.getCompanyByEmailAndMobile(
        //   _emailController.text,
        //   _passwordController.text,
        // );
        final companyProvider = Provider.of<CompanyProvider>(context, listen: false);

        final company = await companyProvider.getCompanyByEmailAndMobile(_emailController.text, _passwordController.text);


        if(!mounted) return;

        if (company != null) {
          // On successful login
          await SessionManager.saveCompany(company);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));
          AppNavigator.toHome();
          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(
          //     builder: (context) => const MainScreen(),
          //   ), //DashboardScreen
          // );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid email or password.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => const MainScreen()),
      // ); //DashboardScreen
      // AppNavigator.toHome();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final maxFormWidth = isTablet ? 500.0 : double.infinity;
    final horizontalPadding = isTablet ? 32.0 : 24.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // title: Text(
        //   "Login",
        //   style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        // ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/app_icon.png',
                width:
                isTablet
                    ? screenWidth * 0.08
                    : screenWidth * 0.12,
              ),
              Text(
                "Welcome back!",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Login to your account to continue.",
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
              _buildInputField(
                label: "Password",
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.indigo.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // New: Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: GoogleFonts.poppins(color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => const CompanyRegistrationScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Register",
                      style: GoogleFonts.poppins(
                        color: Colors.indigo.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
