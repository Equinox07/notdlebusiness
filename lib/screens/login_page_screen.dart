// lib/screens/login_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/screens/company_registration_screen.dart';
import 'package:notdle/screens/forget_password_screen.dart';
import 'package:notdle/screens/personal_account_screen.dart';
import 'package:notdle/services/api_service.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:notdle/utils/helpers.dart';
import 'package:notdle/utils/session_helper.dart';
import 'package:provider/provider.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

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
  bool _obscurePassword = true;

  // Initialize with standard parameters
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
    } catch (e) {
      debugPrint('Error initializing Google Sign-In: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );
      }

      String? deviceImei = await getDeviceImei();
      if (deviceImei == null || deviceImei.isEmpty) {
        deviceImei = await getDeviceId();
      }

      final data = await _apiService.login(
        _emailController.text,
        _passwordController.text,
        deviceImei: deviceImei,
      );

      await _handleLoginSuccess(data, deviceImei);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLoginSuccess(
    Map<String, dynamic>? data,
    String? deviceImei,
  ) async {
    try {
      await _apiService.getCurrentUser();
      final user = await _apiService.getStoredUser();

      if (user == null) {
        throw Exception('Failed to load user data');
      }

      if (deviceImei != null && SessionHelper.isNewDevice(user, deviceImei)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'New device detected. Please verify your identity.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      if (user.hasCompany && user.companyId != null) {
        if (await SessionHelper.shouldSyncCompanyData(user, context)) {
          try {
            final companyData = await _apiService.getCompanyById(
              user.companyId!,
            );
            await SessionManager.saveCompany(companyData);
            if (mounted) {
              final companyProvider = Provider.of<CompanyProvider>(
                context,
                listen: false,
              );
              await companyProvider.companyDao.insertCompany(companyData);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Logged in, but failed to load company data: ${e.toString()}',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }

        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed('dashboard');
        }
      } else {
        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(
            context,
          ).pushReplacementNamed(CompanyRegistrationScreen.tag);
        }
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post-login processing failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (provider == 'Google') {
      try {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(child: CircularProgressIndicator());
            },
          );
        }

        final String baseUrl = _apiService.getUrlBase();

        // App specific variables
        final googleClientId =
            '771814763529-neu8hs5dj6biebjoeo68kdp8d9e10i1t.apps.googleusercontent.com';

        // Construct the url
        // final url = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
        //   'response_type': 'code',
        //   'client_id': googleClientId,
        //   'redirect_uri':
        //       '$callbackUrlScheme1://unreprovable-jacquelynn-unconceived.ngrok-free.dev/api/auth/oauth2/google/callback',
        //   'scope': 'email',
        // });

        // // Present the dialog to the user
        // final result = await FlutterWebAuth2.authenticate(
        //   url: url.toString(),
        //   callbackUrlScheme: callbackUrlScheme,
        // );

        // // Extract code from resulting url
        // final code = Uri.parse(result).queryParameters['code'];

        // debugPrint('Code: $code');

        // // Construct an Uri to Google's oauth2 endpoint
        // final url = Uri.https('www.googleapis.com', 'oauth2/v4/token');

        // // Use this code to get an access token
        // final response = await http.post(
        //   url,
        //   body: {
        //     'client_id': googleClientId,
        //     'redirect_uri': '$callbackUrlScheme:/',
        //     'grant_type': 'authorization_code',
        //     'code': code,
        //   },
        // );

        final String authUrl = '$baseUrl/oauth2/authorization/google';

        final deepLinkResponse = await FlutterWebAuth2.authenticate(
          url: authUrl,
          callbackUrlScheme: 'notdle',
        );

        debugPrint('Result: $deepLinkResponse');

        // Extract code from notdle://oauth/callback?code=xxx
        final Uri uri = Uri.parse(deepLinkResponse);
        final String? code = uri.queryParameters['code'];

        if (code == null) {
          throw Exception('Failed to obtain authentication code from redirect');
        }

        String? deviceImei = await getDeviceImei();
        if (deviceImei == null || deviceImei.isEmpty) {
          deviceImei = await getDeviceId();
        }

        final data = await _apiService.exchangeGoogleCode(
          code,
          deviceId: deviceImei,
        );

        debugPrint('Data: $data');

        await _handleLoginSuccess(data, deviceImei);
      } catch (e) {
        if (mounted) {
          if (Navigator.canPop(context)) Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google Sign-in failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Continue with $provider not implemented yet'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF9F7F2);
    const primaryPurple = Color(0xFF6B11B2);
    const textGrey = Color(0xFF555555);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Image with Fade
          Positioned.fill(
            child: Image.asset('assets/splash_screen.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bgColor.withOpacity(0.8), bgColor],
                  stops: const [0.0, 0.4],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Header with Close and Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.black),
                      ),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: SvgPictureString(svg: ''),
                          ),
                          Text(
                            'Notdle',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Welcome Text
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Welcome back',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage your fashion business with ease.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Field
                        Text(
                          'Email or Phone',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Enter your email or phone',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: primaryPurple,
                                width: 1,
                              ),
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter your email'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Password',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  ForgetPasswordScreen.tag,
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                'Forgot?',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: primaryPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                              onPressed:
                                  () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: primaryPurple,
                                width: 1,
                              ),
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter your password'
                                      : null,
                        ),
                        const SizedBox(height: 24),
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryPurple.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Login',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // OR Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                'OR',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Social Buttons
                        _SocialButton(
                          label: 'Continue with Google',
                          icon: Icons.g_mobiledata,
                          onPressed: () => _handleSocialLogin('Google'),
                        ),
                        const SizedBox(height: 12),
                        _SocialButton(
                          label: 'Continue with Apple',
                          icon: Icons.apple,
                          onPressed: () => _handleSocialLogin('Apple'),
                        ),
                        const SizedBox(height: 32),
                        // Sign Up Link
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                PersonalAccountScreen.tag,
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: GoogleFonts.inter(
                                  color: textGrey,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Start free trial",
                                    style: GoogleFonts.inter(
                                      color: primaryPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1E9F7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryPurple.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: primaryPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.wifi_off,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Internet required for first login.',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: primaryPurple,
                                      ),
                                    ),
                                    Text(
                                      'Offline mode available after setup.',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple helper widget to render SVG-like paths or icons if package:flutter_svg is not available
// Or just use Icon for now to avoid dependency issues if not already in pubspec.
class SvgPictureString extends StatelessWidget {
  final String svg;
  const SvgPictureString({super.key, required this.svg});

  @override
  Widget build(BuildContext context) {
    // Since I don't see flutter_svg in pubspec, I'll use a placeholder Icon
    return const Icon(Icons.architecture, color: Color(0xFF6B11B2), size: 24);
  }
}
