import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/pages/screens/add_measurement_screen.dart';
import 'package:notdle/pages/screens/measurements_screen.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ import

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  // 🔹 Launch phone dialer
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // 🔹 Launch SMS
  Future<void> _sendSMS(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // 🔹 Launch Email
  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull('subject=Hello $email&body=Hi,'),
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

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
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 Profile Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: isTablet ? 60 : 50,
                    backgroundColor: Colors.indigo.shade100,
                    backgroundImage:
                        customer.imageUrl != null
                            ? NetworkImage(customer.imageUrl!) as ImageProvider
                            : (customer.imagePath != null
                                ? FileImage(File(customer.imagePath!))
                                : null),
                    child:
                        (customer.imageUrl == null &&
                                customer.imagePath == null)
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
                  const SizedBox(height: 24),

                  // 📞 Contact Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ContactActionButton(
                        icon: Icons.call,
                        label: "Call",
                        color: Colors.green,
                        onTap: () => _makePhoneCall(customer.phone),
                      ),
                      const SizedBox(width: 20),
                      _ContactActionButton(
                        icon: Icons.message,
                        label: "Message",
                        color: Colors.blue,
                        onTap: () => _sendSMS(customer.phone),
                      ),
                      const SizedBox(width: 20),
                      _ContactActionButton(
                        icon: Icons.email,
                        label: "Email",
                        color: Colors.red,
                        onTap: () => _sendEmail(customer.email ?? ""),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 📊 Customer Stats
            // Text(
            //   "Customer Stats",
            //   style: GoogleFonts.poppins(
            //     fontSize: isTablet ? 18 : 16,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
            // const SizedBox(height: 12),
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(16),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black.withOpacity(0.05),
            //         blurRadius: 12,
            //         offset: const Offset(0, 4),
            //       ),
            //     ],
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: [
            //       _StatTile(
            //         label: "Orders",
            //         value: customer.orders.toString(),
            //         icon: Icons.shopping_bag_outlined,
            //         color: Colors.indigo,
            //       ),
            //       _StatTile(
            //         label: "Last Visit",
            //         value:
            //             "${customer.lastVisit.day}/${customer.lastVisit.month}/${customer.lastVisit.year}",
            //         icon: Icons.calendar_today,
            //         color: Colors.orange,
            //       ),
            //     ],
            //   ),
            // ),
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.straighten,
                          label: 'Measurements',
                          color: Colors.blue.shade600,
                          onTap:
                              () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => AddMeasurementScreen(
                                          customer: customer,
                                        ),
                                  ),
                                ),
                              },
                          // AppNavigator.toMeasurement(customer: customer),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.add_shopping_cart,
                          label: 'New Order',
                          color: Colors.green.shade600,
                          onTap: () => {},
                          // AppNavigator.toOrders(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.history,
                          label: 'Order History',
                          color: Colors.orange.shade600,
                          onTap: () => {},
                          // AppNavigator.toOrders(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.call,
                          label: 'Call Customer',
                          color: Colors.purple.shade600,
                          onTap: () {
                            // TODO: Implement phone call
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 📦 Order History
            const SizedBox(height: 16),

            // Recent Orders
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Orders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => {},
                        // AppNavigator.toOrders(),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildOrderItem('Formal Suit', 'Completed', Colors.green),
                  _buildOrderItem(
                    'Wedding Dress',
                    'In Progress',
                    Colors.orange,
                  ),
                  _buildOrderItem('Casual Shirt', 'Pending', Colors.blue),
                ],
              ),
            ),
            // ListView.separated(
            //   itemCount: customer.orders,
            //   shrinkWrap: true,
            //   physics: const NeverScrollableScrollPhysics(),
            //   separatorBuilder: (_, __) => const SizedBox(height: 12),
            //   itemBuilder: (context, index) {
            //     return Container(
            //       padding: const EdgeInsets.all(16),
            //       decoration: BoxDecoration(
            //         color: Colors.white,
            //         borderRadius: BorderRadius.circular(12),
            //         boxShadow: [
            //           BoxShadow(
            //             color: Colors.black.withOpacity(0.05),
            //             blurRadius: 10,
            //             offset: const Offset(0, 4),
            //           ),
            //         ],
            //       ),
            //       child: Row(
            //         children: [
            //           Container(
            //             padding: const EdgeInsets.all(12),
            //             decoration: BoxDecoration(
            //               color: Colors.indigo.shade50,
            //               borderRadius: BorderRadius.circular(12),
            //             ),
            //             child: const Icon(
            //               Icons.receipt_long,
            //               color: Colors.indigo,
            //             ),
            //           ),
            //           const SizedBox(width: 16),
            //           Expanded(
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text(
            //                   "Order #${index + 1}",
            //                   style: GoogleFonts.poppins(
            //                     fontSize: 15,
            //                     fontWeight: FontWeight.w600,
            //                   ),
            //                 ),
            //                 const SizedBox(height: 4),
            //                 Text(
            //                   "Placed on ${customer.lastVisit.day}/${customer.lastVisit.month}/${customer.lastVisit.year}",
            //                   style: GoogleFonts.poppins(
            //                     fontSize: 13,
            //                     color: Colors.grey.shade600,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //           const Icon(Icons.chevron_right, color: Colors.grey),
            //         ],
            //       ),
            //     );
            //   },
            // ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

Widget _buildActionButton({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
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

// 🔹 Contact Action Button
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

// 🔹 Stats Tile
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

Widget _buildOrderItem(String title, String status, Color statusColor) {
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
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
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
