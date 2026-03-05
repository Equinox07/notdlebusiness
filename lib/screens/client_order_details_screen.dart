// lib/screens/client_order_details_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:notdle/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

// Private data model to hold all fetched details
class _OrderDetailsData {
  final Order order;
  final Customer? customer;
  final Invoice? invoice;
  _OrderDetailsData({required this.order, this.customer, this.invoice});
}

class ClientOrderDetailsScreen extends StatefulWidget {
  static const String tag = "client_order_details";
  final Order order;

  const ClientOrderDetailsScreen({super.key, required this.order});

  @override
  State<ClientOrderDetailsScreen> createState() =>
      _ClientOrderDetailsScreenState();
}

class _ClientOrderDetailsScreenState extends State<ClientOrderDetailsScreen> {
  late Future<_OrderDetailsData?> _orderDetailsFuture;
  late final String _orderId;

  @override
  void initState() {
    super.initState();
    _orderId = widget.order.id;
    _orderDetailsFuture = _fetchOrderDetails();
  }

  Future<_OrderDetailsData?> _fetchOrderDetails() async {
    if (!mounted) return null;
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final data = await orderProvider.getOrderWithDetails(_orderId);

    if (data != null) {
      return _OrderDetailsData(
        order: data.order,
        customer: data.customer,
        invoice: data.invoice,
      );
    }
    debugPrint(
      "Could not fetch details for order ID: $_orderId. 'getOrderWithDetails' returned null.",
    );
    return null;
  }

  void _refreshOrderData() {
    if (mounted) {
      setState(() {
        _orderDetailsFuture = _fetchOrderDetails();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_OrderDetailsData?>(
      future: _orderDetailsFuture,
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: CustomAppBar(
            title: "Order Details",
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshOrderData,
              ),
            ],
          ),
          body: _buildBody(context, snapshot),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _buildFab(context, snapshot),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<_OrderDetailsData?> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      debugPrint(
        "FutureBuilder error: ${snapshot.error}\n${snapshot.stackTrace}",
      );
      return Center(
        child: Text("Error: ${snapshot.error}", style: GoogleFonts.poppins()),
      );
    } else if (!snapshot.hasData || snapshot.data == null) {
      return Center(
        child: Text("Order not found.", style: GoogleFonts.poppins()),
      );
    }

    final orderDetails = snapshot.data!;
    final order = orderDetails.order;
    final customer = orderDetails.customer;
    final invoice = orderDetails.invoice;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OrderSummaryCard(order: order, paymentStatus: order.paymentStatus),
            const SizedBox(height: 16),
            _OrderStatusCard(order: order),
            const SizedBox(height: 16),
            if (order.dueDate != null) ...[
              _TimeInfoCard(dueDate: order.dueDate!),
              const SizedBox(height: 16),
            ],
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              _NotesCard(notes: order.notes!),
              const SizedBox(height: 16),
            ],
            if (invoice != null) ...[
              _InvoiceCard(invoice: invoice),
              const SizedBox(height: 16),
            ],
            _ContactInfoCard(customer: customer),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(
    BuildContext context,
    AsyncSnapshot<_OrderDetailsData?> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting ||
        !snapshot.hasData ||
        snapshot.data == null) {
      return const SizedBox.shrink();
    }

    final orderDetails = snapshot.data!;
    final order = orderDetails.order;

    // Show action button for pending orders
    if (order.status.toLowerCase() == "pending" ||
        order.status.toLowerCase() == "in progress") {
      return FloatingActionButton.extended(
        onPressed: () {
          _showContactBusiness(context);
        },
        backgroundColor: Colors.indigo.shade600,
        label: Text(
          "Contact Business",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.call, color: Colors.white),
      );
    }

    return const SizedBox.shrink();
  }

  void _showContactBusiness(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Contact Business",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "Choose how you'd like to contact the business about this order.",
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement call functionality
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.call),
                label: Text("Call", style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement email functionality
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.email),
                label: Text("Email", style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                ),
              ),
            ],
          ),
    );
  }
}

// 📦 Order Summary Card
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Order No: #${order.orderNumber}",
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

// 📊 Order Status Tracking Card
class _OrderStatusCard extends StatelessWidget {
  final Order order;

  const _OrderStatusCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = ["Ordered", "In Progress", "Ready", "Completed"];
    final currentStep = _getOrderStep(order.status);

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
              "Order Progress",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 100,
              child: Row(
                children: List.generate(steps.length, (index) {
                  final isCompleted = index < currentStep;
                  final isCurrent = index == currentStep;

                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isCompleted || isCurrent
                                    ? Colors.indigo.shade600
                                    : Colors.grey.shade300,
                          ),
                          child: Center(
                            child:
                                isCompleted
                                    ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 22,
                                    )
                                    : Text(
                                      '${index + 1}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          steps[index],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.w500,
                            color:
                                isCurrent
                                    ? Colors.indigo.shade600
                                    : Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getOrderStep(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return 0;
      case "in progress":
        return 1;
      case "ready":
        return 2;
      case "completed":
        return 3;
      default:
        return 0;
    }
  }
}

// ⌚ Time Info Card
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
                  "Expected Delivery",
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
              "Special Requests",
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

// 🧾 Invoice Card Widget
class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  const _InvoiceCard({required this.invoice});

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
                  "Invoice Details",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  "Invoice ID: #${invoice.id.substring(0, 8)}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.monetization_on_outlined,
              label: "Amount: \$${invoice.total?.toStringAsFixed(2)}",
              iconColor: Colors.green,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.receipt_long,
              label: "Status: ${invoice.status}",
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.calendar_today,
              label: "Date: ${DateFormat('MMM d, y').format(invoice.date!)}",
              iconColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

// 📞 Contact Info Card Widget
class _ContactInfoCard extends StatelessWidget {
  final Customer? customer;

  const _ContactInfoCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    if (customer == null) {
      return const SizedBox.shrink();
    }

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
              "Need Help?",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            if (customer!.phone.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      customer!.phone,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.call_outlined,
                      color: Colors.green.shade600,
                    ),
                    onPressed: () {
                      // TODO: Implement call functionality
                    },
                  ),
                ],
              ),
            if (customer!.email != null && customer!.email!.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          customer!.email!,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.email_outlined,
                          color: Colors.blue.shade600,
                        ),
                        onPressed: () {
                          // TODO: Implement email functionality
                        },
                      ),
                    ],
                  ),
                ],
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
    switch (status.toLowerCase()) {
      case "completed":
        return Colors.green.shade600;
      case "in progress":
        return Colors.blue.shade600;
      case "pending":
        return Colors.orange.shade600;
      case "cancelled":
        return Colors.red.shade600;
      case "ready":
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
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
    switch (status.toLowerCase()) {
      case "paid":
        return Colors.green.shade600;
      case "partial":
        return Colors.blue.shade600;
      case "unpaid":
        return Colors.orange.shade600;
      case "refunded":
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
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
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
