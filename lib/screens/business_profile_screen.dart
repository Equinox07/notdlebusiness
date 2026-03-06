import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/models/user_model.dart';
import 'package:notdle/providers/image_provider.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/api_provider.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:provider/provider.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  static const String tag = "business_profile_screen";

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  late Future<Company?> _companyFuture;
  User? _currentUser;
  String? _userImagePath;

  @override
  void initState() {
    super.initState();
    _companyFuture = SessionManager.getCompany();
    _loadData();
  }

  Future<void> _loadData() async {
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    final imageProvider = Provider.of<AppImageProvider>(context, listen: false);

    final company = await SessionManager.getCompany();
    final user = await apiProvider.apiService.getStoredUser();

    String? userImagePath;
    if (user != null) {
      final images = await imageProvider.getImages(user.id, "user");
      if (images.isNotEmpty) {
        userImagePath = images.last.localPath;
      }
    }

    if (mounted) {
      setState(() {
        _companyFuture = Future.value(company);
        _currentUser = user;
        _userImagePath = userImagePath;
      });
    }
  }

  // Future<void> _loadCompany() async {
  //   setState(() {
  //     _companyFuture = SessionManager.getCompany();
  //   });
  // }

  Future<void> _pickImage() async {
    if (_currentUser == null) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF6200EE),
                  ),
                  title: Text(
                    "Take a photo",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF6200EE),
                  ),
                  title: Text(
                    "Choose from gallery",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      if (!mounted) return;
      final imageProvider = Provider.of<AppImageProvider>(
        context,
        listen: false,
      );
      await imageProvider.saveSingleImage(
        "",
        ownerId: _currentUser!.id,
        ownerType: "user",
        file: File(pickedFile.path),
      );

      final images = await imageProvider.getImages(_currentUser!.id, "user");
      if (images.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _userImagePath = images.last.localPath;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6200EE).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.business_rounded,
                color: Color(0xFF6200EE),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Business Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Account overview',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.more_horiz_rounded,
                color: Color(0xFF424242),
                size: 18,
              ),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF424242),
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.black.withValues(alpha: 0.02),
          ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildProfileHeader(company),
                const SizedBox(height: 16),
                _buildUpgradeBanner(),
                const SizedBox(height: 16),
                _buildSectionTitle("BUSINESS DETAILS"),
                const SizedBox(height: 8),
                _buildBusinessDetailsSection(company),
                const SizedBox(height: 16),
                _buildSectionTitle("CONTACT INFORMATION"),
                const SizedBox(height: 8),
                _buildContactInfoSection(company),
                const SizedBox(height: 16),
                _buildSectionTitle("ACCOUNT SETTINGS"),
                const SizedBox(height: 8),
                _buildAccountSettingsSection(context),
                const SizedBox(height: 16),
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
        GestureDetector(
          onTap: _currentUser != null ? () => _pickImage() : null,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFD4AF37), // Accurate Gold
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      _userImagePath != null
                          ? FileImage(File(_userImagePath!))
                          : null,
                  child:
                      _userImagePath == null
                          ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          )
                          : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6200EE), // Primary Purple
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          company?.ownerName ?? "Elena Rossi",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "STITCHFLOW ELITE MEMBER",
          style: GoogleFonts.poppins(
            fontSize: 10,
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Unlock advanced inventory tracking and priority support.",
                style: GoogleFonts.poppins(
                  fontSize: 11,
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
