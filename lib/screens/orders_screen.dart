// lib/screens/orders_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:notdle/screens/create_order_screen.dart';
import 'package:notdle/screens/order_details_screen.dart';
import 'package:notdle/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

// A new data class to hold the combined Order and Customer data.
// This avoids using a FutureBuilder inside the list items.
class _OrderWithCustomer {
  final Order order;
  final String customerName;

  _OrderWithCustomer({required this.order, required this.customerName});
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  static const String tag = "orders";

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // The future now fetches our combined data model.
  late Future<List<_OrderWithCustomer>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrdersWithCustomers();
  }

  // This method is now more efficient, fetching all data upfront.
  Future<List<_OrderWithCustomer>> _fetchOrdersWithCustomers() async {
    if (!mounted) return [];
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );

    // 1. Fetch all orders
    await orderProvider.fetchOrders();
    final orders = orderProvider.orders;

    final List<_OrderWithCustomer> detailedOrders = [];

    // 2. For each order, fetch its customer and create the combined object.
    for (final order in orders) {
      final customer = await customerProvider.getCustomerById(order.customerId);
      detailedOrders.add(
        _OrderWithCustomer(
          order: order,
          customerName: customer?.name ?? "Unknown Customer",
        ),
      );
    }
    return detailedOrders;
  }

  // A single, robust method to handle refreshing the list.
  void _refreshOrders() {
    if (mounted) {
      setState(() {
        _ordersFuture = _fetchOrdersWithCustomers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomAppBar(title: "Orders"),
      body: RefreshIndicator(
        onRefresh: () async => _refreshOrders(),
        child: FutureBuilder<List<_OrderWithCustomer>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: GoogleFonts.poppins(),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                      "No Orders Yet",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap 'New Order' to get started.",
                      style: GoogleFonts.poppins(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            } else {
              final orders = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  16,
                  12,
                  80,
                ), // Add padding for FAB
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final detailedOrder = orders[index];
                  return _OrderCard(
                    order: detailedOrder.order,
                    customerName: detailedOrder.customerName,
                    onTap: () async {
                      // Await navigation and refresh if data might have changed.
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => OrderDetailsScreen(
                                order: detailedOrder.order,
                              ),
                        ),
                      );
                      _refreshOrders();
                    },
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Await navigation and refresh the list after a new order is created.
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateOrderScreen()),
          );
          _refreshOrders();
        },
        label: Text(
          "New Order",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.indigo.shade600,
      ),
    );
  }
}

// A redesigned, "classic" Order Card Widget
class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.customerName,
    required this.onTap,
  });

  final Order order;
  final String customerName;
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
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    customerName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
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
