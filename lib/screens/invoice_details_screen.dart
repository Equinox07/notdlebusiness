// lib/screens/invoice_details_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/db/database_helper.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:notdle/widgets/status_chip.dart';
import 'package:provider/provider.dart';
// import 'package:notdle/widgets/status_chip.dart';

// Private data model to hold all fetched details
class _InvoiceDetailsData {
  final Invoice invoice;
  final Order? order;
  final Customer? customer;

  _InvoiceDetailsData({required this.invoice, this.order, this.customer});
}

// lib/screens/invoice_details_screen.dart

class InvoiceDetailsScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  late Future<_InvoiceDetailsData> _invoiceDetailsFuture;
  late Future<Company?> _companyFuture;
  // final DatabaseHelper _dbHelper = DatabaseHelper.instance;


  @override
  void initState() {
    super.initState();
    _invoiceDetailsFuture = _fetchInvoiceDetails();
    _companyFuture = SessionManager.getCompany();
  }

  Future<_InvoiceDetailsData> _fetchInvoiceDetails() async {
    // final order = await DatabaseHelper.instance.getOrderById(
    //   widget.invoice.orderId,
    // );

    final order = await Provider.of<OrderProvider>(context, listen: false).getOrderById(widget.invoice.orderId);
        // .get(widget.invoice.customerId);

    final customer = await Provider.of<CustomerProvider>(context, listen: false)
        .getCustomerById(widget.invoice.customerId); //DatabaseHelper.instance.fetchCustomerById(widget.invoice.customerId,);

    return _InvoiceDetailsData(
      invoice: widget.invoice,
      order: order,
      customer: customer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Invoice Details",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: FutureBuilder<_InvoiceDetailsData>(
        future: _invoiceDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Invoice not found."));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Info Section
                  FutureBuilder<Company?>(
                    future: _companyFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Text('Error loading company data.');
                      } else if (snapshot.hasData) {
                        final company = snapshot.data!;
                        return _buildCompanyInfoCard(company);
                      } else {
                        return const Text('Company data not found.');
                      }
                    },
                  ),
                  _InvoiceHeaderCard(invoice: data.invoice),
                  const SizedBox(height: 16),
                  if (data.customer != null)
                    _CustomerInfoCard(customer: data.customer!),
                  const SizedBox(height: 16),
                  if (data.order != null) _OrderInfoCard(order: data.order!),
                  const SizedBox(height: 16),
                  _InvoiceBreakdownCard(invoice: data.invoice),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // A helper method to build the Company Info Card
  Widget _buildCompanyInfoCard(Company company) {
    return SizedBox(
      width: double.infinity, // Makes the card stretch end-to-end
      child: Card(
        elevation: 4, // Increased elevation for a standout effect
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo Placeholder
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.indigo,
                // Conditionally load the image
                backgroundImage: company.imagePath != null
                    ? FileImage(File(company.imagePath!)) as ImageProvider
                    : null,
                child: company.imagePath == null
                    ? const Icon(Icons.business, color: Colors.white, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.businessName,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      company.email,
                      style: GoogleFonts.poppins(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company.mobile,
                      style: GoogleFonts.poppins(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerInfoCard extends StatelessWidget {
  final Customer customer;

  const _CustomerInfoCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Customer Details",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.person_outline, label: customer.name),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.phone_outlined, label: customer.phone),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.email_outlined, label: customer.email ?? "N/A"),
        ],
      ),
    );
  }
}


class _InvoiceHeaderCard extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceHeaderCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensures the container is full-width
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ), // Adds a subtle border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Invoice #${invoice.id.substring(0, 8)}",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMMM d, y').format(invoice.date),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          // Use a Row to align the amount and status chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${invoice.totalAmount.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade600,
                ),
              ),
              PaymentStatusChip(status: invoice.status),
            ],
          ),
        ],
      ),
    );
  }
}
// lib/screens/invoice_details_screen.dart

class _OrderInfoCard extends StatelessWidget {
  final Order order;

  const _OrderInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Details",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.shopping_bag_outlined, label: order.title),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.calendar_today,
            label: "Due: ${order.dueDate ?? "N/A"}",
          ),
        ],
      ),
    );
  }
}

// lib/screens/invoice_details_screen.dart

class _InvoiceBreakdownCard extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceBreakdownCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Invoice Breakdown",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const Divider(height: 24),
          _AmountRow(label: "Subtotal", amount: invoice.totalAmount),
          const SizedBox(height: 8),
          _AmountRow(
            label: "Tax",
            amount: 0.00, // Placeholder
            isBold: false,
          ),
          const Divider(height: 24),
          _AmountRow(
            label: "Total Amount",
            amount: invoice.totalAmount,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

// lib/screens/invoice_details_screen.dart

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;

  const _AmountRow({
    required this.label,
    required this.amount,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
