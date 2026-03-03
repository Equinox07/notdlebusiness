import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/api_provider.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:notdle/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  static const String tag = "business_profile_screen";

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  late Future<Company?> _companyFuture;

  @override
  void initState() {
    super.initState();
    _companyFuture = SessionManager.getCompany();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: CustomAppBar(
        title: "Business Profile",
        centerTitle: true,
        isLight: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black87),
            onPressed: () {},
          ),
        ],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Company?>(
        future: _companyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final company = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildProfileHeader(company),
                const SizedBox(height: 24),
                _buildUpgradeBanner(),
                const SizedBox(height: 24),
                _buildSectionTitle("BUSINESS DETAILS"),
                const SizedBox(height: 8),
                _buildBusinessDetailsSection(company),
                const SizedBox(height: 20),
                _buildSectionTitle("CONTACT INFORMATION"),
                const SizedBox(height: 8),
                _buildContactInfoSection(company),
                const SizedBox(height: 20),
                _buildSectionTitle("ACCOUNT SETTINGS"),
                const SizedBox(height: 8),
                _buildAccountSettingsSection(context),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Company? company) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFFD4AF37), // Accurate Gold
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    company?.imagePath != null
                        ? FileImage(File(company!.imagePath!))
                        : null,
                child:
                    company?.imagePath == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6200EE), // Primary Purple
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          company?.ownerName ?? "Elena Rossi",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "STITCHFLOW ELITE MEMBER",
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6200EE),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              company?.country ?? "Milan, Italy",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpgradeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6200EE), Color(0xFF311B92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6200EE).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 0,
            top: 0,
            child: Icon(Icons.auto_awesome, color: Colors.white24, size: 32),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upgrade to Premium",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Unlock advanced inventory tracking and priority support.",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => AppNavigator.toSubscriptionBilling(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6200EE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(
                    "Upgrade Now",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black45,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildBusinessDetailsSection(Company? company) {
    return _buildContainerSection([
      _buildRefinedTile(
        icon: Icons.storefront_outlined,
        label: "Business Name",
        value: company?.businessName ?? "Rossi Couture Milan",
        onTap: () => AppNavigator.toCompanyProfile(),
      ),
      _buildSectionDivider(),
      _buildRefinedTile(
        icon: Icons.category_outlined,
        label: "Specialty",
        value: company?.genderSpecialty ?? "High-End Bridal & Evening Wear",
        onTap: () => AppNavigator.toCompanyProfile(),
      ),
      _buildSectionDivider(),
      _buildRefinedTile(
        icon: Icons.image_outlined,
        label: "Business Logo",
        onTap: () => AppNavigator.toCompanyProfile(),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.image, color: Colors.grey, size: 18),
        ),
      ),
    ]);
  }

  Widget _buildContactInfoSection(Company? company) {
    return _buildContainerSection([
      _buildRefinedTile(
        icon: Icons.mail_outline,
        label: "Email Address",
        value: company?.email ?? "elena@rossicouture.com",
        onTap: () {},
      ),
      _buildSectionDivider(),
      _buildRefinedTile(
        icon: Icons.phone_outlined,
        label: "Phone",
        value:
            "${company?.countryCode ?? '+39'} ${company?.mobile ?? '02 1234 5678'}",
        onTap: () {},
      ),
    ]);
  }

  Widget _buildAccountSettingsSection(BuildContext context) {
    return _buildContainerSection([
      _buildRefinedTile(
        icon: Icons.lock_outline,
        value: "Change Password",
        isSimple: true,
        onTap: () {},
      ),
      _buildSectionDivider(),
      _buildRefinedTile(
        icon: Icons.notifications_none_outlined,
        value: "Notifications",
        isSimple: true,
        onTap: () => AppNavigator.toNotificationSettings(),
        trailing: Transform.scale(
          scale: 0.8,
          child: Switch.adaptive(
            value: true,
            onChanged: (v) {},
            activeColor: const Color(0xFF6200EE),
          ),
        ),
      ),
      _buildSectionDivider(),
      _buildRefinedTile(
        icon: Icons.logout,
        value: "Log Out",
        isSimple: true,
        valueColor: Colors.red,
        iconColor: Colors.red,
        onTap: () => _handleLogout(context),
      ),
    ]);
  }

  Widget _buildContainerSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRefinedTile({
    required IconData icon,
    String? label,
    String? value,
    required VoidCallback onTap,
    Widget? trailing,
    bool isSimple = false,
    Color? valueColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? const Color(0xFF6200EE), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child:
                  isSimple
                      ? Text(
                        value!,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: valueColor ?? Colors.black87,
                        ),
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (label != null)
                            Text(
                              label,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.black45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if (label != null) const SizedBox(height: 2),
                          if (value != null)
                            Text(
                              value,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: valueColor ?? Colors.black87,
                              ),
                            ),
                        ],
                      ),
            ),
            trailing ??
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black12,
                  size: 14,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 54,
      color: Colors.grey.shade50,
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    try {
      await apiProvider.apiService.logout();
      if (context.mounted) {
        AppNavigator.toLogin2();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
