import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:notdle/providers/api_provider.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:notdle/pages/dashboards/dashboard_screen.dart';

class InitialSetupScreen extends StatefulWidget {
  static const String tag = 'initial-setup';

  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  String _selectedCurrency = 'USD - US Dollar (\$)';
  String _measurementSystem = 'Metric'; // Metric or Imperial
  bool _pushNotifications = true;
  String _themeMode = 'Light'; // Light or Dark
  bool _isLoading = false;

  final Color primaryPurple = const Color(0xFF6B11B2);
  final Color textGrey = const Color(0xFF64748B);
  final Color bgColor = const Color(0xFFF9F7F2);
  final Color cardBg = Colors.white;

  Future<void> _finishSetup() async {
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    final companyProvider = Provider.of<CompanyProvider>(
      context,
      listen: false,
    );
    var company = companyProvider.company;

    // Fallback to SessionManager if provider company is null
    if (company == null) {
      company = await SessionManager.getCompany();
      if (company != null) {
        companyProvider.setCompany(company);
      }
    }

    if (company == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No company found to update')),
      );
      return;
    }

    setState(() => _isLoading = true);
    context.loaderOverlay.show();

    try {
      // Extract currency code from string like "USD - US Dollar ($)"
      final currencyCode = _selectedCurrency.split(' ')[0];

      final patchData = {
        'currency': currencyCode,
        'measurementSystem': _measurementSystem.toUpperCase(),
        'enablePushNotifications': _pushNotifications,
        'appAppearance': _themeMode.toUpperCase(),
      };

      await apiProvider.apiService.patchCompany(company.id, patchData);

      // Update local company data
      final updatedCompany = company.copyWith(
        currency: currencyCode,
        measurementSystem: _measurementSystem.toUpperCase(),
        enablePushNotifications: _pushNotifications,
        appAppearance: _themeMode.toUpperCase(),
      );

      await SessionManager.saveCompany(updatedCompany);
      companyProvider.setCompany(updatedCompany);

      // Mark initial setup as completed in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('initialScreenCompleted', true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Initial setup completed successfully!')),
      );

      // Navigate to dashboard
      Navigator.pushReplacementNamed(context, DashboardScreen.tag);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        context.loaderOverlay.hide();
      }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: const Color(0xFF0F172A),
                          size: 18,
                        ),
                      ),
                    ),
                    Text(
                      'STEP 3 OF 3',
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
                const SizedBox(height: 24),
                // Title
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Initial Setup',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Let’s customize your workspace to fit your\nbusiness needs.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: textGrey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Business Currency Card
                _buildSetupCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Business Currency',
                  subtitle: 'Main transaction currency',
                  child: _buildCurrencyDropdown(),
                ),
                const SizedBox(height: 12),
                // Measurement System Card
                _buildSetupCard(
                  icon: Icons.straighten_outlined,
                  title: 'Measurement System',
                  subtitle: 'Used for pattern making',
                  child: _buildMeasurementToggle(),
                ),
                const SizedBox(height: 12),
                // Push Notifications Card
                _buildSetupCard(
                  icon: Icons.notifications_none_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Order and deadline alerts',
                  child: Switch(
                    value: _pushNotifications,
                    onChanged:
                        (value) => setState(() => _pushNotifications = value),
                    activeColor: primaryPurple,
                  ),
                  isRow: true,
                ),
                const SizedBox(height: 12),
                // App Appearance Card
                _buildSetupCard(
                  icon: Icons.palette_outlined,
                  title: 'App Appearance',
                  subtitle: 'Choose your preferred aesthetic',
                  child: _buildThemeSelection(),
                ),
                const SizedBox(height: 24),
                // Finish Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _finishSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      shadowColor: primaryPurple.withOpacity(0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Finish Setup',
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
    bool isRow = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child:
          isRow
              ? Row(
                children: [
                  _buildIconBox(icon),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  child,
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildIconBox(icon),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  child,
                ],
              ),
    );
  }

  Widget _buildIconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E0FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: primaryPurple, size: 24),
    );
  }

  Widget _buildCurrencyDropdown() {
    return GestureDetector(
      onTap: () {
        showCurrencyPicker(
          context: context,
          showFlag: true,
          showCurrencyName: true,
          showCurrencyCode: true,
          onSelect: (Currency currency) {
            setState(() {
              _selectedCurrency =
                  '${currency.code} - ${currency.name} (${currency.symbol})';
            });
          },
          theme: CurrencyPickerThemeData(
            backgroundColor: Colors.white,
            flagSize: 25,
            titleTextStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            subtitleTextStyle: GoogleFonts.inter(fontSize: 14, color: textGrey),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedCurrency,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Icon(Icons.swap_vert, color: textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementToggle() {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              'Metric (cm)',
              _measurementSystem == 'Metric',
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              'Imperial (in)',
              _measurementSystem == 'Imperial',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _measurementSystem = label.split(' ')[0]),
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryPurple : textGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelection() {
    return Row(
      children: [
        Expanded(child: _buildThemeCard('Light', _themeMode == 'Light')),
        const SizedBox(width: 16),
        Expanded(
          child: _buildThemeCard(
            'Dark',
            _themeMode == 'Dark',
            isEnabled: false,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeCard(
    String mode,
    bool isSelected, {
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? () => setState(() => _themeMode = mode) : null,
      child: Column(
        children: [
          Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primaryPurple : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color:
                          mode == 'Light'
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        if (isSelected && isEnabled)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: primaryPurple,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        // Mock UI elements inside the theme card
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 8,
                                decoration: BoxDecoration(
                                  color:
                                      mode == 'Light'
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE5E0FF),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color:
                                          mode == 'Light'
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            mode,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryPurple : textGrey,
            ),
          ),
          if (!isEnabled)
            Text(
              'Coming Soon',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
