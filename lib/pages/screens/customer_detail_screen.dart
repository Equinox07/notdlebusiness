import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/pages/screens/customer_orders_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;

  static const String tag = "customer_details";

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Customer Details",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section (Profile Image & Name)
              _CustomerHeader(customer: customer),

              const SizedBox(height: 16),

              // Contact Actions
              _ContactActionsCard(customer: customer),

              const SizedBox(height: 16),

              // Quick Actions
              _QuickActionsCard(customer: customer),

              const SizedBox(height: 16),

              // Recent Orders
              _RecentOrdersCard(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Widget for the Customer Header
class _CustomerHeader extends StatelessWidget {
  final Customer customer;

  const _CustomerHeader({required this.customer});

  @override
  Widget build(BuildContext context) {
    // The `isTablet` variable is now correctly placed inside the build method
    // so it can access the runtime context.
    final isTablet = (MediaQuery.of(context).size.width > 600);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: isTablet ? 60 : 50,
            backgroundColor: Colors.indigo.shade100,
            backgroundImage:
                customer.imagePath != null
                    ? FileImage(File(customer.imagePath!)) as ImageProvider
                    : null,
            child:
                (customer.imagePath == null)
                    ? Icon(
                      Icons.person,
                      size: isTablet ? 70 : 60,
                      color: Colors.indigo.shade600,
                    )
                    : null,
          ),
          const SizedBox(height: 16),
          Text(
            customer.name,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            customer.email ?? "",
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Widget for Contact Actions
class _ContactActionsCard extends StatelessWidget {
  final Customer customer;

  const _ContactActionsCard({required this.customer});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSMS(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull('subject=Hello ${customer.name}&body=Hi,'),
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = (MediaQuery.of(context).size.width > 600);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ContactActionButton(
            icon: Icons.call,
            label: "Call",
            color: Colors.green,
            onTap: () => _makePhoneCall(customer.phone),
          ),
          _ContactActionButton(
            icon: Icons.message,
            label: "Message",
            color: Colors.blue,
            onTap: () => _sendSMS(customer.phone),
          ),
          _ContactActionButton(
            icon: Icons.email,
            label: "Email",
            color: Colors.red,
            onTap: () => _sendEmail(customer.email ?? ""),
          ),
        ],
      ),
    );
  }
}

// Reusable Widget for Quick Actions
class _QuickActionsCard extends StatelessWidget {
  final Customer customer;
  const _QuickActionsCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.straighten,
                  label: 'Measurements',
                  color: Colors.blue.shade600,
                  onTap: () => AppNavigator.toMeasurement2(customer: customer),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.add_shopping_cart,
                  label: 'New Order',
                  color: Colors.green.shade600,
                  onTap: () => debugPrint("Create Order"),
                  // AppNavigator.toCreateOrder(
                  // customer: null,
                  // ), // AppNavigator.toOrders(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.history,
                  label: 'Order History',
                  color: Colors.orange.shade600,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                CustomerOrdersScreen(customer: customer),
                      ),
                    );
                  }, // AppNavigator.toOrders(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.call,
                  label: 'Call Customer',
                  color: Colors.purple.shade600,
                  onTap:
                      () => launchUrl(Uri(scheme: 'tel', path: customer.phone)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Reusable Widget for Recent Orders
class _RecentOrdersCard extends StatelessWidget {
  const _RecentOrdersCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
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
                'Recent Orders',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 8),
          _OrderItem(
            title: 'Formal Suit',
            status: 'Completed',
            statusColor: Colors.green,
          ),
          _OrderItem(
            title: 'Wedding Dress',
            status: 'In Progress',
            statusColor: Colors.orange,
          ),
          _OrderItem(
            title: 'Casual Shirt',
            status: 'Pending',
            statusColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}

// Reusable Action Button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Contact Action Button
class _ContactActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

// Reusable Order Item
class _OrderItem extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;

  const _OrderItem({
    required this.title,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
