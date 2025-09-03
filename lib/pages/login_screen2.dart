import 'package:flutter/material.dart';
import 'package:notdle/navigation/app_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth > 600 ? 48.0 : 24.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.1),
                      // Logo/Title section
                      Column(
                        children: [
                          Container(
                            width: constraints.maxWidth > 600 ? 100 : 80,
                            height: constraints.maxWidth > 600 ? 100 : 80,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(
                                constraints.maxWidth > 600 ? 25 : 20,
                              ),
                            ),
                            child: Icon(
                              Icons.content_cut,
                              color: Colors.white,
                              size: constraints.maxWidth > 600 ? 50 : 40,
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.03),
                          Text(
                            'AWU Tailoring',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: constraints.maxWidth > 600 ? 32 : null,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: constraints.maxHeight * 0.01),
                          Text(
                            'Precision in every stitch',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: constraints.maxWidth > 600 ? 18 : null,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(height: constraints.maxHeight * 0.06),

                      // Form section
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth > 600 ? 400 : double.infinity,
                        ),
                        child: Column(
                          children: [
                            // Email field
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: constraints.maxWidth > 600 ? 20 : 16,
                                  horizontal: 16,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),

                            // Password field
                            TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: constraints.maxWidth > 600 ? 20 : 16,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.03),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => AppNavigator.toHome(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: constraints.maxWidth > 600 ? 20 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth > 600 ? 18 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),

                            // Forgot password
                            TextButton(
                              onPressed: () {
                                // TODO: Implement forgot password
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.w500,
                                  fontSize: constraints.maxWidth > 600 ? 16 : 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.1),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
