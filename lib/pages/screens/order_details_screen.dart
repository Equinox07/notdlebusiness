import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailsScreen extends StatelessWidget {
  static const String tag = "order_details";

  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Order Details",
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
            children: const [
              _OrderSummaryCard(),
              SizedBox(height: 16),
              // Updated: New Time Card
              _TimeInfoCard(dueDate: "Sep 30, 2025"),
              SizedBox(height: 16),
              // Updated: New Customer Info Card
              _CustomerInfoCard(
                customerName: "Emma Johnson",
                phone: "+1 (555) 123-4567",
                email: "emma.j@example.com",
              ),
              SizedBox(height: 16),
              _OrderTimelineCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// 📦 Order Summary Card
class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.indigo.shade600,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Wedding Dress",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Order ID: #12345",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                _StatusChip(status: "In Progress"),
                SizedBox(width: 8),
                _PaymentStatusChip(status: "Partial"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ⌚ New Time Card
class _TimeInfoCard extends StatelessWidget {
  final String dueDate;
  const _TimeInfoCard({required this.dueDate});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Icon(
              Icons.access_time_filled,
              color: Colors.orange.shade600,
              size: 24,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Due Date",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dueDate,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 👤 Updated Customer Info Card
class _CustomerInfoCard extends StatelessWidget {
  final String customerName;
  final String phone;
  final String email;

  const _CustomerInfoCard({
    required this.customerName,
    required this.phone,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Customer Info",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.call_outlined,
                        color: Colors.green.shade600,
                      ),
                      onPressed: () {
                        // Action to call the customer
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.email_outlined,
                        color: Colors.blue.shade600,
                      ),
                      onPressed: () {
                        // Action to email the customer
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.person_outline,
              label: customerName,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: phone,
              iconColor: Colors.green,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.email_outlined,
              label: email,
              iconColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

// ⏳ Order Timeline Card
class _OrderTimelineCard extends StatelessWidget {
  const _OrderTimelineCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Order Timeline",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 16),
            _TimelineItem(
              title: "Order Placed",
              subtitle: "Aug 15, 2025",
              isCurrent: false,
              isFirst: true,
            ),
            _TimelineItem(
              title: "Measurements Taken",
              subtitle: "Aug 18, 2025",
              isCurrent: false,
            ),
            _TimelineItem(
              title: "In Progress",
              subtitle: "Aug 20, 2025",
              isCurrent: true,
            ),
            _TimelineItem(
              title: "Completed",
              subtitle: "Sep 5, 2025",
              isCurrent: false,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Status Chip Widget
class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: statusColor,
          fontSize: 14,
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
      default:
        return Colors.grey;
    }
  }
}

// Reusable Payment Status Chip Widget
class _PaymentStatusChip extends StatelessWidget {
  final String status;

  const _PaymentStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getPaymentColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payment, size: 16, color: statusColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.poppins(
              color: statusColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentColor(String status) {
    switch (status) {
      case "Full":
        return Colors.green.shade600;
      case "Partial":
        return Colors.blue.shade600;
      case "Pending":
        return Colors.orange.shade600;
      default:
        return Colors.grey;
    }
  }
}

// Reusable Info Row Widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

// Reusable Timeline Item
class _TimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCurrent;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    required this.subtitle,
    this.isCurrent = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            // Line before circle
            if (!isFirst)
              Container(
                height: 20,
                width: 2,
                color: isCurrent ? Colors.blue.shade600 : Colors.grey.shade300,
              ),
            // Status Circle
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: isCurrent ? Colors.blue.shade600 : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            // Line after circle
            if (!isLast)
              Container(
                height: 20,
                width: 2,
                color: isCurrent ? Colors.blue.shade600 : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      isCurrent ? Colors.blue.shade800 : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
