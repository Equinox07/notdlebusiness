import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/widgets/custom_app_bar.dart';

class SubscriptionBillingScreen extends StatelessWidget {
  const SubscriptionBillingScreen({super.key});

  static const String tag = "subscription_billing_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: CustomAppBar(
        title: "Subscription & Billing",
        centerTitle: true,
        isLight: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActiveMembershipCard(),
            const SizedBox(height: 24),
            _buildSectionTitle("Plan Options"),
            const SizedBox(height: 8),
            _buildBoutiquePlanCard(),
            const SizedBox(height: 12),
            _buildAtelierPlanCard(),
            const SizedBox(height: 24),
            _buildSectionTitle("Payment Method"),
            const SizedBox(height: 8),
            _buildPaymentMethodCard(),
            const SizedBox(height: 24),
            _buildSectionTitle("Billing History"),
            const SizedBox(height: 8),
            _buildBillingHistorySection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.black45,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildActiveMembershipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ACTIVE MEMBERSHIP",
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "CURRENT",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "StitchFlow Pro",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Next renewal",
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "Oct 12, 2024",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6200EE),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  "Manage",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoutiquePlanCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "BOUTIQUE",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "\$49",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                " /month",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFeatureRow("5 Team Members", isChecked: true),
          _buildFeatureRow("100 Designs / mo", isChecked: true),
          _buildFeatureRow("Standard Analytics", isChecked: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFF3E5F5)),
                backgroundColor: const Color(0xFFFBF7FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "Switch to Boutique",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6200EE),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtelierPlanCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6200EE).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6200EE).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -38,
            right: -25,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFBC02D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Text(
                "PREMIUM CHOICE",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "ATELIER",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6200EE),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFFBC02D),
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "\$99",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    " /month",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFeatureRow(
                "Unlimited Users",
                isChecked: true,
                premium: true,
              ),
              _buildFeatureRow(
                "AI Fashion Trend Insights",
                isChecked: true,
                premium: true,
              ),
              _buildFeatureRow(
                "Priority Atelier Support",
                isChecked: true,
                premium: true,
              ),
              _buildFeatureRow(
                "Custom Branding",
                isChecked: true,
                premium: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6200EE),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Upgrade to Atelier",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
    String feature, {
    bool isChecked = false,
    bool premium = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: premium ? const Color(0xFFFBC02D) : const Color(0xFF6200EE),
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            feature,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.credit_card, color: Colors.grey, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Visa ending in 4242",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Expires 12/26",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "Edit",
              style: GoogleFonts.poppins(
                color: const Color(0xFF6200EE),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingHistorySection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
      child: Column(
        children: [
          _buildHistoryItem("INV-0092", "Sep 12, 2023", "\$79.00"),
          _buildSectionDivider(),
          _buildHistoryItem("INV-0081", "Aug 12, 2023", "\$79.00"),
          _buildSectionDivider(),
          _buildHistoryItem("INV-0075", "Jul 12, 2023", "\$79.00"),
        ],
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade50);
  }

  Widget _buildHistoryItem(String id, String date, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Invoice #$id",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "$date • $amount",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.file_download_outlined,
              color: Color(0xFF6200EE),
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
