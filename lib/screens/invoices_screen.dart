// lib/screens/invoices_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/invoice_provider.dart';
import 'package:notdle/screens/invoice_details_screen.dart';
import 'package:provider/provider.dart';

// A new data class to hold the combined Invoice and Customer data.
// This avoids using a FutureBuilder inside the list items.
class _InvoiceWithCustomer {
  final Invoice invoice;
  final String customerName;

  _InvoiceWithCustomer({required this.invoice, required this.customerName});
}

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  static const String tag = "invoices_list";

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  // The future now fetches our combined data model.
  late Future<List<_InvoiceWithCustomer>> _invoicesFuture;

  @override
  void initState() {
    super.initState();
    _invoicesFuture = _fetchInvoicesWithCustomers();
  }

  // This method is now more efficient, fetching all data upfront.
  Future<List<_InvoiceWithCustomer>> _fetchInvoicesWithCustomers() async {
    if (!mounted) return [];
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);

    // 1. Fetch all invoices
    await invoiceProvider.fetchInvoices();
    final invoices = invoiceProvider.invoices;

    final List<_InvoiceWithCustomer> detailedInvoices = [];

    // 2. For each invoice, fetch its customer and create the combined object.
    for (final invoice in invoices) {
      final customer = await customerProvider.getCustomerById(invoice.customerId);
      detailedInvoices.add(
        _InvoiceWithCustomer(
          invoice: invoice,
          customerName: customer?.name ?? "Unknown Customer",
        ),
      );
    }
    return detailedInvoices;
  }

  // A single, robust method to handle refreshing the list.
  void _refreshInvoices() {
    if (mounted) {
      setState(() {
        _invoicesFuture = _fetchInvoicesWithCustomers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Invoices",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshInvoices(),
        child: FutureBuilder<List<_InvoiceWithCustomer>>(
          future: _invoicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              debugPrint("InvoicesScreen Error: ${snapshot.error}");
              return Center(
                child: Text(
                  "An error occurred.",
                  style: GoogleFonts.poppins(),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      "No Invoices Found",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Invoices you create will appear here.",
                      style: GoogleFonts.poppins(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            } else {
              final invoices = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                itemCount: invoices.length,
                itemBuilder: (context, index) {
                  final detailedInvoice = invoices[index];
                  return InvoiceCard(
                    invoice: detailedInvoice.invoice,
                    customerName: detailedInvoice.customerName,
                    onTap: () async {
                      // Await navigation and refresh if data might have changed.
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => InvoiceDetailsScreen(invoice: detailedInvoice.invoice),
                        ),
                      );
                      _refreshInvoices();
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

// A redesigned, "classic" Invoice Card Widget
class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.customerName,
    required this.onTap,
  });

  final Invoice invoice;
  final String customerName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = invoice.status != 'Paid' && invoice.date.isBefore(DateTime.now());
    final String formattedDueDate = DateFormat('MMM d, y').format(invoice.date);

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.title,
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
                            Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "\$${invoice.totalAmount.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade700,
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
                  _StatusChip(status: invoice.status),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: isOverdue ? Colors.red.shade700 : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOverdue ? "Overdue: $formattedDueDate" : "Due: $formattedDueDate",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isOverdue ? Colors.red.shade700 : Colors.grey.shade600,
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
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
    final IconData icon = _getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: statusColor),
          const SizedBox(width: 5),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green.shade600;
      case 'Pending':
        return Colors.orange.shade600;
      case 'Draft':
        return Colors.grey.shade700;
      case 'Void':
        return Colors.red.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Paid':
        return Icons.check_circle;
      case 'Pending':
        return Icons.hourglass_bottom;
      case 'Draft':
        return Icons.edit_note;
      case 'Void':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}