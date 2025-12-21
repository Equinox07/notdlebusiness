// lib/screens/customer_orders_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:notdle/screens/order_details_screen.dart';
import 'package:notdle/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class CustomerOrdersScreen extends StatefulWidget {
  final Customer customer;

  const CustomerOrdersScreen({super.key, required this.customer});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Use postFrameCallback to ensure the context is available
    // and to fetch data right after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshOrders();
    });
  }

  // Centralized refresh logic
  Future<void> _refreshOrders() async {
    // Check if the widget is still in the tree before using the provider.
    if (mounted) {
      // We call the provider to fetch the data. The Consumer will handle the UI update.
      // We assert that customer.id is not null, as it's essential for this screen.
      await Provider.of<OrderProvider>(
        context,
        listen: false,
      ).fetchOrdersForCustomer(widget.customer.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(title: "${widget.customer.name}'s Orders"),
      // Use a Consumer to listen for changes in the OrderProvider
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.customerOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No Orders Found",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "This customer has no orders yet.",
                    style: GoogleFonts.poppins(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final orders = orderProvider.customerOrders;
          // Use RefreshIndicator for pull-to-refresh functionality
          return RefreshIndicator(
            onRefresh: _refreshOrders,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderCard(
                  order: order,
                  onTap: () async {
                    // Await navigation to refresh the list if changes were made
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsScreen(order: order),
                      ),
                    );
                    _refreshOrders();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Redesigned "classic" Order Card to match other screens
class OrderCard extends StatelessWidget {
  const OrderCard({required this.order, required this.onTap, super.key});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String getFormattedDueDate(String? dueDate) {
      if (dueDate == null || dueDate.isEmpty) {
        return "No due date";
      }
      try {
        final date = DateFormat("yyyy-M-d").parse(dueDate);
        return "Due: ${DateFormat('MMM d, y').format(date)}";
      } catch (e) {
        return "Invalid date";
      }
    }

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top Section: Primary Info ---
              Text(
                order.title,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // This screen is already filtered for a customer, so we don't need to show the name again.
              // We can show the Order ID instead for better context.
              const SizedBox(height: 4),
              Text(
                "Order ID: ${order.id.substring(0, 8)}...",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(height: 1),
              ),
              // --- Bottom Section: Status & Metadata ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Group status chips together
                  Row(
                    children: [
                      _StatusChip(status: order.status),
                      const SizedBox(width: 8),
                      _PaymentStatusChip(status: order.paymentStatus),
                    ],
                  ),
                  // Due date aligned to the right
                  Text(
                    getFormattedDueDate(order.dueDate),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: statusColor,
          fontSize: 12,
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
}

// Reusable Payment Status Chip Widget
class _PaymentStatusChip extends StatelessWidget {
  final String status;
  const _PaymentStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getPaymentColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getPaymentIcon(status), size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.poppins(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentColor(String status) {
    switch (status) {
      case "Paid":
        return Colors.green.shade600;
      case "Partial":
        return Colors.blue.shade600;
      case "Unpaid":
        return Colors.orange.shade600;
      case "Refunded":
        return Colors.red.shade600;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getPaymentIcon(String status) {
    switch (status) {
      case "Paid":
        return Icons.check_circle_outline;
      case "Partial":
        return Icons.pie_chart_outline;
      case "Unpaid":
        return Icons.hourglass_empty_rounded;
      case "Refunded":
        return Icons.remove_circle_outline;
      default:
        return Icons.help_outline;
    }
  }
}
