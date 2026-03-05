// lib/screens/customer_detail_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/providers/measurement_provider.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:notdle/screens/client_order_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  static const String tag = "customer_details";

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.customer.id != null) {
        Provider.of<MeasurementProvider>(
          context,
          listen: false,
        ).fetchMeasurementsWithCustomer(widget.customer.id!);

        Provider.of<OrderProvider>(
          context,
          listen: false,
        ).fetchOrdersForCustomer(widget.customer.id!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: CustomAppBar(
        title: "Client Profile",
        centerTitle: true,
        isLight: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF6200EE)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildOrdersTab(),
                _buildMeasurementsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppNavigator.toCreateNewOrder(),
        backgroundColor: const Color(0xFF6200EE),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF3E8FF), width: 3),
              ),
              child: CircleAvatar(
                radius: 54, // slightly smaller avatar
                backgroundColor: const Color(0xFFF3E8FF),
                backgroundImage:
                    widget.customer.imagePath != null
                        ? FileImage(File(widget.customer.imagePath!))
                        : null,
                child:
                    widget.customer.imagePath == null
                        ? const Icon(
                          Icons.person,
                          size: 54,
                          color: Color(0xFF6200EE),
                        )
                        : null,
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6200EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  "VIP",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.customer.name,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.customer.phone,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: const Color(0xFF6200EE),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeaderAction(
              Icons.call,
              () => launchUrl(Uri(scheme: 'tel', path: widget.customer.phone)),
            ),
            const SizedBox(width: 12),
            _buildHeaderAction(
              Icons.chat_bubble,
              () => launchUrl(Uri(scheme: 'sms', path: widget.customer.phone)),
            ),
            const SizedBox(width: 12),
            _buildHeaderAction(
              Icons.email,
              () =>
                  widget.customer.email != null
                      ? launchUrl(
                        Uri(scheme: 'mailto', path: widget.customer.email!),
                      )
                      : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF6200EE), size: 18),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed:
                  () => AppNavigator.toCreateOrder(customer: widget.customer),
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: Text(
                "New Order",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6200EE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => AppNavigator.toNewMeasurement(widget.customer),
              icon: const Icon(Icons.straighten, size: 18),
              label: Text(
                "Measure",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6200EE),
                side: const BorderSide(color: Color(0xFFE9D8F4), width: 1.5),
                backgroundColor: const Color(0xFFFAF5FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorColor: const Color(0xFF6200EE),
        indicatorWeight: 3,
        labelColor: const Color(0xFF6200EE),
        unselectedLabelColor: Colors.black45,
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        tabs: const [
          Tab(text: "Details"),
          Tab(text: "Orders"),
          Tab(text: "Measurements"),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    // final styles =
    //     widget.customer.stylePreferences
    //         ?.split(", ")
    //         .where((s) => s.isNotEmpty)
    //         .toList() ??
    //     [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ), // reduced from 24
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard("TOTAL SPENT", "\$4,250.00"),
              ), // Could be calculated from orders
              const SizedBox(width: 12), // reduced from 16
              Expanded(child: _buildMetricCard("LAST ORDER", "Oct 12")),
            ],
          ),
          const SizedBox(height: 16), // reduced from 20/24
          // if (styles.isNotEmpty ||
          //     widget.customer.stylePreferences == null) ...[
          //   // show default if empty for design matching
          //   _buildStylePreferences(
          //     styles.isEmpty
          //         ? [
          //           "Minimalist",
          //           "Silk Fabrics",
          //           "Neutral Palette",
          //           "Tailored Fit",
          //           "Sustainable",
          //         ]
          //         : styles,
          //   ),
          //   const SizedBox(height: 16), // reduced from 24
          // ],
          // if (widget.customer.notes != null &&
          //     widget.customer.notes!.isNotEmpty) ...[
          //   _buildNotesSection(),
          //   const SizedBox(height: 20), // reduced from 32
          // ],
          _buildRecentOrders(),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16), // reduced from 20
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // reduced from 24
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600, // less bold
              color: const Color(0xFF717171), // darker grey
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6), // reduced from 8
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18, // reduced from 20
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStylePreferences(List<String> styles) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // reduced from 24
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // reduced from 24
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Style Preferences",
                style: GoogleFonts.poppins(
                  fontSize: 16, // reduced from 18
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Icon(Icons.edit, color: Color(0xFF6200EE), size: 18),
            ],
          ),
          const SizedBox(height: 12), // reduced from 16
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: styles.map((s) => _buildTag(s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF), // very soft purple background
        border: Border.all(
          color: const Color(0xFFE9D8F4),
        ), // darker purple border
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF6200EE),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // reduced from 24
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // reduced from 24
      ),
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Text(
      //       "Client Notes",
      //       style: GoogleFonts.poppins(
      //         fontSize: 16, // reduced
      //         fontWeight: FontWeight.w600,
      //         color: Colors.black,
      //       ),
      //     ),
      //     const SizedBox(height: 10), // reduced
      //     Text(
      //       widget.customer.notes!,
      //       style: GoogleFonts.poppins(
      //         fontSize: 13, // reduced
      //         color: const Color(0xFF717171),
      //         height: 1.4,
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Orders",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600, // slightly less bold
                color: Colors.black,
              ),
            ),
            Text(
              "See all",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6200EE),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildOrderItem(
          "Custom Silk Blouse",
          "Order #SF-1204",
          "\$320.00",
          "Oct 12, 2023",
          "COMPLETED",
          const Color(0xFFE6F4EA), // Soft green bg
          const Color(0xFF1E8E3E), // Dark green text
        ),
        const SizedBox(height: 12),
        _buildOrderItem(
          "Tailored Wool Blazer",
          "Order #SF-1188",
          "\$850.00",
          "Sep 28, 2023",
          "IN PROGRESS",
          const Color(0xFFF3E8FF), // Soft purple bg
          const Color(0xFF6200EE), // Purple text
        ),
      ],
    );
  }

  Widget _buildOrderItem(
    String title,
    String subtitle,
    String price,
    String date,
    String status,
    Color statusBg,
    Color statusText,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // slightly more rounded
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top
        children: [
          Container(
            width: 72, // Larger image area
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image_outlined, color: Colors.black26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // Pill shape for status
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: statusText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF9095A0),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFFBCC1CC),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = provider.customerOrders;

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  "No orders yet",
                  style: GoogleFonts.poppins(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    final dateStr =
        order.dueDate != null && order.dueDate!.isNotEmpty
            ? "Due: ${_formatDueDate(order.dueDate!)}"
            : "No due date";

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ClientOrderDetailsScreen(order: order),
          ),
        );
        // Refresh orders after returning from details screen
        if (!mounted) return;
        if (widget.customer.id != null) {
          Provider.of<OrderProvider>(
            context,
            listen: false,
          ).fetchOrdersForCustomer(widget.customer.id!);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  dateStr,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFFBCC1CC),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusChip(order.status),
                const SizedBox(width: 8),
                _buildPaymentStatusChip(order.paymentStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDueDate(String dueDate) {
    try {
      final date = DateFormat("yyyy-M-d").parse(dueDate);
      return DateFormat('MMM d, y').format(date);
    } catch (e) {
      return dueDate;
    }
  }

  Widget _buildStatusChip(String status) {
    final Color statusColor = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: statusColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusChip(String status) {
    final Color statusColor = _getPaymentStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: statusColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green.shade600;
      case "In Progress":
        return Colors.blue.shade600;
      case "Pending":
        return Colors.orange.shade600;
      case "Cancelled":
        return Colors.red.shade600;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case "Paid":
        return Colors.green.shade600;
      case "Partially Paid":
        return Colors.orange.shade600;
      case "Unpaid":
        return Colors.red.shade600;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildMeasurementsTab() {
    return Consumer<MeasurementProvider>(
      builder: (context, provider, child) {
        final measurements = provider.customerMeasurements;

        if (measurements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.straighten, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  "No measurements recorded yet",
                  style: GoogleFonts.poppins(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: measurements.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final m = measurements[index];
            return _buildMeasurementItem(m);
          },
        );
      },
    );
  }

  Widget _buildMeasurementItem(Measurement m) {
    final dateStr = DateFormat('MMM d, yyyy').format(m.createdDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  m.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                dateStr,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFFBCC1CC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children:
                m.measurementValues.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF9095A0),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        entry.value.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
