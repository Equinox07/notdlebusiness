import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/order_details.dart';
import 'package:notdle/models/order.dart';

class OrderDetailsScreen extends StatelessWidget {
  static const String tag = "order_details";
  final Order order;
  // This screen will need to fetch the detailed info based on the provided order.
  // For this example, we'll use a dummy method.

  const OrderDetailsScreen({super.key, required this.order});

  // A dummy method to fetch detailed order information.
  // In a real app, this would be an asynchronous call to a database or API.
  OrderDetails _fetchDetailedOrder(String orderId) {
    // This is a placeholder for a real data source.
    // The details returned depend on the specific order ID.
    if (orderId == "1") {
      return OrderDetails(
        order: order,
        customerPhone: "+1 (555) 123-4567",
        customerEmail: "emma.j@example.com",
        paymentStatus: "Partial",
        dueDate: "Sep 30, 2025",
        timeline: [
          OrderEvent(title: "Order Placed", date: "Aug 15, 2025"),
          OrderEvent(title: "Measurements Taken", date: "Aug 18, 2025"),
          OrderEvent(
            title: "In Progress",
            date: "Aug 20, 2025",
            isCurrent: true,
          ),
        ],
        notes:
            "Client requested an extra-long train and a pearl-beaded bodice. Contacted vendor for materials.",
      );
    } else if (orderId == "2") {
      return OrderDetails(
        order: order,
        customerPhone: "+1 (555) 987-6543",
        customerEmail: "michael.c@example.com",
        paymentStatus: "Full",
        dueDate: "Aug 25, 2025",
        timeline: [
          OrderEvent(title: "Order Placed", date: "Aug 10, 2025"),
          OrderEvent(title: "Measurements Taken", date: "Aug 12, 2025"),
          OrderEvent(title: "Completed", date: "Aug 25, 2025", isCurrent: true),
        ],
        notes: null,
      );
    } else {
      return OrderDetails(
        order: order,
        customerPhone: "+1 (555) 555-1111",
        customerEmail: "lisa.r@example.com",
        paymentStatus: "Pending",
        dueDate: "Oct 15, 2025",
        timeline: [
          OrderEvent(
            title: "Order Placed",
            date: "Sep 1, 2025",
            isCurrent: true,
          ),
        ],
        notes: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderDetails = _fetchDetailedOrder(order.id);

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
            children: [
              _OrderSummaryCard(
                order: order,
                paymentStatus: orderDetails.paymentStatus,
              ),
              const SizedBox(height: 16),
              _TimeInfoCard(dueDate: orderDetails.dueDate),
              const SizedBox(height: 16),
              _CustomerInfoCard(
                customerName: order.customer.name,
                phone: orderDetails.customerPhone,
                email: orderDetails.customerEmail,
              ),
              const SizedBox(height: 16),
              if (orderDetails.notes != null) ...[
                _NotesCard(notes: orderDetails.notes!),
                const SizedBox(height: 16),
              ],
              _OrderTimelineCard(timeline: orderDetails.timeline),
            ],
          ),
        ),
      ),
    );
  }
}

// 📄 Notes Card Widget
class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Notes",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              notes,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 📦 Flat Order Summary Card
class _OrderSummaryCard extends StatelessWidget {
  final Order order;
  final String paymentStatus;

  const _OrderSummaryCard({required this.order, required this.paymentStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.indigo.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
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
                    order.title,
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
              "Order ID: #${order.id}",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatusChip(status: order.status),
                const SizedBox(width: 8),
                _PaymentStatusChip(status: paymentStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ⌚ Flat Time Info Card
class _TimeInfoCard extends StatelessWidget {
  final String dueDate;
  const _TimeInfoCard({required this.dueDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
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

// 👤 Flat Customer Info Card
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
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
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.email_outlined,
                        color: Colors.blue.shade600,
                      ),
                      onPressed: () {},
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

// ⏳ Flat Order Timeline Card
class _OrderTimelineCard extends StatelessWidget {
  final List<OrderEvent> timeline;

  const _OrderTimelineCard({required this.timeline});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Timeline",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 16),
            ...timeline.map((event) {
              final isFirst = timeline.indexOf(event) == 0;
              final isLast = timeline.indexOf(event) == timeline.length - 1;
              return _TimelineItem(
                title: event.title,
                subtitle: event.date,
                isCurrent: event.isCurrent,
                isFirst: isFirst,
                isLast: isLast,
              );
            }).toList(),
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
            if (!isFirst)
              Container(
                height: 20,
                width: 2,
                color: isCurrent ? Colors.blue.shade600 : Colors.grey.shade300,
              ),
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: isCurrent ? Colors.blue.shade600 : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
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
