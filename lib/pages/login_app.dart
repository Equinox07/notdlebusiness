import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/pages/dashboard_screen.dart';
import 'package:notdle/pages/signup_page.dart';

class LoginApp extends StatelessWidget {
  static const String tag = "login";

  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = true;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final maxFormWidth = isTablet ? 500.0 : double.infinity;
    final horizontalPadding = isTablet ? 32.0 : 24.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0F7FA), Color(0xFFFFFFFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Top Right Decorative Blur Shape
          Positioned(
            top: 100,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  width: isTablet ? 140 : 100,
                  height: isTablet ? 200 : 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Container(
                width: maxFormWidth,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Top logo and flag
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/logo.png',
                                      width:
                                          isTablet
                                              ? screenWidth * 0.08
                                              : screenWidth * 0.12,
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            fontSize: isTablet ? 14 : 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/us_flag.png',
                                    width:
                                        isTablet
                                            ? screenWidth * 0.05
                                            : screenWidth * 0.08,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 60),

                            // Sign In Title
                            Text(
                              'Sign In',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 32 : 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Username Field
                            _buildTextField(
                              label: 'Username',
                              suffixIcon: Icons.arrow_drop_down,
                            ),

                            const SizedBox(height: 20),

                            // Password Field
                            _buildTextField(
                              label: 'Password',
                              obscureText: obscurePassword,
                              suffixIconButton: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Remember me
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      rememberMe = value ?? false;
                                    });
                                  },
                                ),
                                Text(
                                  "Remember me",
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C76B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.green.withOpacity(0.3),
                                ),
                                onPressed: () => AppNavigator.toHome(),
                                child: Text(
                                  "LOGIN",
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 20 : 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            Center(
                              child: GestureDetector(
                                onTap: () => AppNavigator.toSignUp2(),

                                // Navigate to Sign Up
                                child: RichText(
                                  text: const TextSpan(
                                    text: "Don't have an account? ",
                                    style: TextStyle(color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: "Sign Up",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer Info
                    Column(
                      children: [
                        Text(
                          "Version: 5.0.0",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Device: 739sc666c6666666666666",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom input builder with shadow
  Widget _buildTextField({
    required String label,
    bool obscureText = false,
    IconData? suffixIcon,
    Widget? suffixIconButton,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon:
              suffixIconButton ??
              (suffixIcon != null ? Icon(suffixIcon) : null),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
