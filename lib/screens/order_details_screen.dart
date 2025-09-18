// lib/screens/order_details_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/db/database_helper.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:notdle/screens/create_invoice_screen.dart';
import 'package:notdle/screens/update_order_modal.dart';
import 'package:provider/provider.dart';

// Private data model to hold all fetched details
class _OrderDetailsData {
  final Order order;
  final Customer? customer;
  final Invoice? invoice;
  _OrderDetailsData({required this.order, this.customer, this.invoice});
}

class OrderDetailsScreen extends StatefulWidget {
  static const String tag = "order_details";
  // final String orderId;
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  // final dbHelper = DatabaseHelper.instance;
  late Future<_OrderDetailsData?> _orderDetailsFuture;
  late String _selectedStatus;
  late String _selectedPaymentStatus;

  final List<String> _orderStatuses = [
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled'
  ];
  final List<String> _paymentStatuses = [
    'Unpaid',
    'Paid',
    'Refunded',
    'Partial'
  ];





  @override
  void initState() {
    super.initState();
    _orderDetailsFuture = _fetchOrderDetails();
    _selectedStatus = widget.order.status;
    _selectedPaymentStatus = widget.order.paymentStatus;
  }

  // Helper method to update the order status
  Future<void> _updateOrderStatus(String? newStatus) async {
    if (newStatus != null && newStatus != _selectedStatus) {

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      final updateOrder = widget.order.copyWith(
        status: newStatus
      );

      // await dbHelper.updateOrderStatus(widget.order.id, newStatus);
      await orderProvider.updateOrder(updateOrder);

      setState(() {
        _selectedStatus = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );
    }
  }

  // Helper method to update the payment status
  Future<void> _updatePaymentStatus(String? newPaymentStatus) async {
    if (newPaymentStatus != null && newPaymentStatus != _selectedPaymentStatus) {

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      final updateOrder = widget.order.copyWith(
          paymentStatus: newPaymentStatus
      );
      await orderProvider.updateOrder(updateOrder);

      // await dbHelper.updateOrderPaymentStatus(widget.order.id, newPaymentStatus);
      setState(() {
        _selectedPaymentStatus = newPaymentStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment status updated to $newPaymentStatus')),
      );
    }
  }

  Future<_OrderDetailsData?> _fetchOrderDetails() async {
    // final data = await dbHelper.getOrderWithDetails(widget.order.id);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final data = await orderProvider.getOrderWithDetails(widget.order.id);
    if (data != null) {
      return _OrderDetailsData(
        order: data.order,
        customer: data.customer,
        invoice: data.invoice,
      );
    }
    return null;
  }

  // Method to refresh the screen after modal is closed
  void _refreshOrderData() {
    setState(() {
      _orderDetailsFuture = _fetchOrderDetails();
    });
  }

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
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: () {
            showDialog(context: context, builder: (BuildContext context) {
              return UpdateOrderModal(order: widget.order, onOrderUpdated: _refreshOrderData);
            });
          })
        ],
      ),
      body: FutureBuilder<_OrderDetailsData?>(
        future: _orderDetailsFuture,
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
          } else if (!snapshot.hasData) {
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
                  // _buildSectionTitle('Status & Payment'),
                  // const SizedBox(height: 8),
                  // Card(
                  //   elevation: 1,
                  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(16.0),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         _buildDropdown(
                  //           'Order Status',
                  //           _selectedStatus,
                  //           _orderStatuses,
                  //               (newValue) => _updateOrderStatus(newValue),
                  //         ),
                  //         const SizedBox(height: 16),
                  //         _buildDropdown(
                  //           'Payment Status',
                  //           _selectedPaymentStatus,
                  //           _paymentStatuses,
                  //               (newValue) => _updatePaymentStatus(newValue),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  _OrderSummaryCard(
                    order: order,
                    paymentStatus: order.paymentStatus,
                  ),
                  const SizedBox(height: 16),
                  if (order.dueDate != null) ...[
                    _TimeInfoCard(dueDate: order.dueDate!),
                    const SizedBox(height: 16),
                  ],
                  if (customer != null) ...[
                    _CustomerInfoCard(
                      customerName: customer.name,
                      phone: customer.phone,
                      email: customer.email ?? 'N/A',
                    ),
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
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FutureBuilder<_OrderDetailsData?>(
        future: _orderDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const SizedBox.shrink(); // Hide the button while loading
          }
          final order = snapshot.data!.order;
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CreateInvoiceScreen(order: order),
                ),
              );
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
        },
      ),
    );
  }
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
    items: items.map((item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      );
    }).toList(),
    onChanged: onChanged,
  );
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
              label: "Amount: \$${invoice.totalAmount.toStringAsFixed(2)}",
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
              label: "Date: ${DateFormat('MMM d, y').format(invoice.date)}",
              iconColor: Colors.blue,
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
      case "Paid":
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
    // <-- Added the build method
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


