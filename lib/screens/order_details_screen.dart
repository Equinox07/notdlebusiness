// lib/screens/order_details_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:notdle/screens/create_invoice_screen.dart';
import 'package:notdle/screens/update_order_modal.dart';
import 'package:notdle/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as _logger;
import 'dart:math' as _math;
import 'dart:typed_data' as _typed_data;
import 'package:url_launcher/url_launcher.dart';

// Private data model to hold all fetched details
class _OrderDetailsData {
  final Order order;
  final Customer? customer;
  final Invoice? invoice;
  _OrderDetailsData({required this.order, this.customer, this.invoice});
}

class OrderDetailsScreen extends StatefulWidget {
  static const String tag = "order_details";
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required Order order,
    required this.orderId,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Future<_OrderDetailsData?> _orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    _orderDetailsFuture = _fetchOrderDetails();
  }

  Future<_OrderDetailsData?> _fetchOrderDetails() async {
    if (!mounted) return null;
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final data = await orderProvider.getOrderWithDetails(widget.orderId);

    if (data != null) {
      return _OrderDetailsData(
        order: data.order,
        customer: data.customer,
        invoice: data.invoice,
      );
    }
    debugPrint(
      "Could not fetch details for order ID: ${widget.orderId}. 'getOrderWithDetails' returned null.",
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
        final orderDetails = snapshot.data;
        final order = orderDetails?.order;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: CustomAppBar(
            title: 'Order Details',
            actions: [
              if (snapshot.connectionState == ConnectionState.done &&
                  order != null)
                IconButton(
                  icon: const Icon(Icons.edit_note),
                  onPressed: () => _showUpdateOrderModal(context, order),
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
      // Added more detailed error logging for debugging.
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
            _OrderStatusCard(status: order.status),
            const SizedBox(height: 16),
            _TimeInfoCard(orderDate: order.createdAt!, dueDate: order.dueAt),
            const SizedBox(height: 16),
            if (customer != null) ...[
              _CustomerInfoCard(customer: customer),
              const SizedBox(height: 16),
            ],
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              _NotesCard(notes: order.notes!),
              const SizedBox(height: 16),
            ],
            if (invoice != null) ...[
              _InvoiceCard(invoice: invoice, order: order),
              const SizedBox(height: 16),
            ],
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
      return const SizedBox.shrink(); // Hide FAB while loading or if no data
    }

    final orderDetails = snapshot.data!;
    // Hide FAB if an invoice already exists
    if (orderDetails.invoice != null) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () async {
        // Navigate and await result to refresh if an invoice was created.
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => CreateInvoiceScreen(order: orderDetails.order),
          ),
        );
        if (result == true && mounted) {
          _refreshOrderData();
        }
      },
      backgroundColor: Colors.indigo.shade600,
      label: Text(
        "Create Invoice",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      icon: const Icon(Icons.receipt, color: Colors.white),
    );
  }

  void _showUpdateOrderModal(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdateOrderModal(
          order: order,
          onOrderUpdated: _refreshOrderData,
        );
      },
    );
  }

  // Helper widget to build section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  // Helper widget to build the dropdowns
  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade600, width: 2),
        ),
      ),
      value: value,
      items:
          items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
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
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade200.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
  final String status;

  const _OrderStatusCard({required this.status});

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

  @override
  Widget build(BuildContext context) {
    int currentStep = _getOrderStep(status);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Status',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _Step(
                  title: 'Ordered',
                  isCompleted: currentStep >= 0,
                  isFirst: true,
                  isLast: false,
                ),
                _Connector(isCompleted: currentStep >= 1),
                _Step(
                  title: 'In Progress',
                  isCompleted: currentStep >= 1,
                  isFirst: false,
                  isLast: false,
                ),
                _Connector(isCompleted: currentStep >= 2),
                _Step(
                  title: 'Ready',
                  isCompleted: currentStep >= 2,
                  isFirst: false,
                  isLast: false,
                ),
                _Connector(isCompleted: currentStep >= 3),
                _Step(
                  title: 'Completed',
                  isCompleted: currentStep >= 3,
                  isFirst: false,
                  isLast: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;

  const _Step({
    required this.title,
    required this.isCompleted,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? Colors.indigo.shade600 : Colors.grey.shade300,
            border: Border.all(
              color:
                  isCompleted ? Colors.indigo.shade600 : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child:
              isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w500,
            color: isCompleted ? Colors.indigo.shade600 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  final bool isCompleted;

  const _Connector({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 2,
            color: isCompleted ? Colors.indigo.shade600 : Colors.grey.shade300,
          ),
          const SizedBox(height: 32), // To align with text
        ],
      ),
    );
  }
}

// ⌚ Flat Time Info Card
class _TimeInfoCard extends StatelessWidget {
  final DateTime orderDate;
  final DateTime? dueDate;
  const _TimeInfoCard({required this.orderDate, this.dueDate});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Timeline",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTimeDetail(
                  context,
                  icon: Icons.calendar_today_outlined,
                  label: 'Order Date',
                  value: DateFormat('d MMM yyyy').format(orderDate),
                ),
                if (dueDate != null) ...[
                  const SizedBox(width: 16),
                  _buildTimeDetail(
                    context,
                    icon: Icons.event_available_outlined,
                    label: 'Due Date',
                    value: DateFormat('d MMM yyyy').format(dueDate!),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDetail(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.indigo.shade600),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

// 👤 Flat Customer Info Card
class _CustomerInfoCard extends StatelessWidget {
  final Customer customer;

  const _CustomerInfoCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
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
                    if (customer.phone != null && customer.phone!.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.call_outlined,
                          color: Colors.green.shade600,
                        ),
                        onPressed:
                            () => launchUrl(Uri.parse('tel:${customer.phone}')),
                      ),
                    if (customer.email != null && customer.email!.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.email_outlined,
                          color: Colors.blue.shade600,
                        ),
                        onPressed:
                            () => launchUrl(
                              Uri.parse('mailto:${customer.email}'),
                            ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    if (customer.phone != null && customer.phone!.isNotEmpty)
                      Text(
                        customer.phone!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
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

// 📄 Notes Card Widget
class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
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

// 🧾 Invoice Card Widget
class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final Order order;
  const _InvoiceCard({required this.invoice, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
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
            Row(
              children: [
                _buildTimeDetail(
                  context,
                  icon: Icons.monetization_on_outlined,
                  label: 'Amount',
                  value: NumberFormat.currency(
                    symbol: '₦',
                  ).format(invoice.total),
                ),
                const SizedBox(width: 16),
                _buildTimeDetail(
                  context,
                  icon: Icons.receipt_long,
                  label: 'Status',
                  value: invoice.status,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTimeDetail(
                  context,
                  icon: Icons.calendar_today_outlined,
                  label: 'Order Date',
                  value: DateFormat('d MMM yyyy').format(order.createdAt!),
                ),
                if (order.dueAt != null) ...[
                  const SizedBox(width: 16),
                  _buildTimeDetail(
                    context,
                    icon: Icons.event_available_outlined,
                    label: 'Due Date',
                    value: DateFormat('d MMM yyyy').format(order.dueAt!),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDetail(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.indigo.shade600),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w600,
          fontSize: 12,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getPaymentStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: _getPaymentStatusColor(status),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case "Paid":
        return Colors.green.shade600;
      case "Partially Paid":
        return Colors.blue.shade600;
      case "Unpaid":
        return Colors.orange.shade600;
      case "Refunded":
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
