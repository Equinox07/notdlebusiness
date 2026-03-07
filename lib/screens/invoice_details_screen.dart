// lib/screens/invoice_details_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/invoice_item.dart';
import 'package:notdle/models/payment.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/payment_provider.dart';
import 'package:notdle/screens/create_invoice_screen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

const _kPurple = Color(0xFF6200EE);
const _kGold = Color(0xFFD4AF37);
const _kBg = Color(0xFFF8F9FB);

class InvoiceDetailsScreen extends StatefulWidget {
  final Invoice invoice;

  static const tag = 'invoice-details';

  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  double _totalPaid = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  void _loadPaymentData() async {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );
    final totalPaid = await paymentProvider.getTotalPaidForInvoice(
      widget.invoice.id,
    );
    setState(() {
      _totalPaid = totalPaid;
    });
  }

  Future<void> _generateAndSendInvoice(
    Invoice invoice,
    dynamic navigatorKey,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "INVOICE",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text("Invoice No: ${invoice.invoiceNumber}"),
              pw.Divider(),
              pw.Text("Total Amount: \$${invoice.total!.toStringAsFixed(2)}"),
              pw.SizedBox(height: 20),
              pw.Text("Items:"),
              // pw.Column(
              //   children:
              //       invoice.items.map((item) => _buildItemRow(item)).toList(),
              // ),
            ],
          );
        },
      ),
    );

    // This opens the native share sheet
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${invoice.invoiceNumber}.pdf',
    );
  }

  Future<void> _navigateToEdit(
    BuildContext context,
    dynamic navigatorKey,
  ) async {
    // Navigate to the CreateInvoiceScreen with the current invoice for editing
    Customer? customer = await Provider.of<CustomerProvider>(
      context,
      listen: false,
    ).getCustomerById(widget.invoice.customerId);
    final updatedInvoice = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateInvoiceScreen(
              invoice: widget.invoice, // Pass the existing invoice to the form
              customer: customer,
            ),
      ),
    );

    if (updatedInvoice != null) {
      // Refresh the UI with updated data from the provider
    }
  }

  void _showRecordPaymentDialog(BuildContext context) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String paymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Record Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items:
                    ['Cash', 'Bank Transfer', 'Credit Card']
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    paymentMethod = value;
                  }
                },
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  // Show an error or return
                  return;
                }

                final newPayment = Payment(
                  invoiceId: widget.invoice.id,
                  amount: amount,
                  amountCents: (amount * 100).toInt(),
                  paymentDate: DateTime.now(),
                  status: 'Completed',
                  method: paymentMethod,
                  notes: notesController.text,
                );

                final paymentProvider = Provider.of<PaymentProvider>(
                  context,
                  listen: false,
                );
                await paymentProvider.addPayment(newPayment);

                // Reload data and close dialog
                _loadPaymentData();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          widget.invoice.invoiceNumber ?? 'N/A',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Action: Share or Download PDF
            },
            icon: const Icon(Icons.share_outlined, color: _kPurple),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 24),
            _buildAmountCard(),
            const SizedBox(height: 24),
            _buildClientSection(context),
            const SizedBox(height: 24),
            _buildItemsList(),
            const SizedBox(height: 24),
            _buildSummaryTable(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildStatusHeader() {
    bool isPaid = widget.invoice.status.toLowerCase() == 'paid';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Issued on",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey),
            ),
            Text(
              widget.invoice.issueDate != null
                  ? DateFormat('MMM dd, yyyy').format(widget.invoice.issueDate!)
                  : 'N/A',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                isPaid
                    ? Colors.green.withOpacity(0.1)
                    : _kGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.invoice.status.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isPaid ? Colors.green : _kGold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountCard() {
    final outstanding = widget.invoice.total! - _totalPaid;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kPurple,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Total Amount",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "\$${widget.invoice.total!.toStringAsFixed(2)}",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    "Total Paid",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "\$${_totalPaid.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "Outstanding",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "\$${outstanding.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "BILL TO",
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<Customer?>(
          future: Provider.of<CustomerProvider>(
            context,
            listen: false,
          ).getCustomerById(widget.invoice.customerId),
          builder: (context, snapshot) {
            final customer = snapshot.data;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _kBg,
                    child: const Icon(Icons.person_outline, color: _kPurple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer?.name ?? 'Unknown Customer',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          customer?.phone.isNotEmpty == true
                              ? customer!.phone
                              : 'No phone number',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (customer?.email != null &&
                                  customer!.email!.trim().isNotEmpty)
                              ? customer.email!
                              : 'No email',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SERVICES",
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.invoice.items.map((item) => _buildItemRow(item)),
      ],
    );
  }

  Widget _buildItemRow(InvoiceItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Qty: ${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "\$${item.amount.toStringAsFixed(2)}",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _summaryRow(
            "Subtotal",
            "\$${widget.invoice.subtotal!.toStringAsFixed(2)}",
          ),
          const SizedBox(height: 10),
          _summaryRow("Tax", "+\$${widget.invoice.tax!.toStringAsFixed(2)}"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _summaryRow(
            "Grand Total",
            "\$${widget.invoice.total!.toStringAsFixed(2)}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.blueGrey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? _kPurple : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // EDIT BUTTON
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text("Edit"),
                onPressed:
                    () => _navigateToEdit(context, Navigator.of(context)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: _kPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // SEND BUTTON
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment, size: 18, color: Colors.white),
                label: const Text(
                  "Record Payment",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _showRecordPaymentDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
