// lib/widgets/update_invoice_modal.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/db/database_helper.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/providers/invoice_provider.dart';
import 'package:provider/provider.dart';

class UpdateInvoiceModal extends StatefulWidget {
  final Invoice invoice;
  final Function() onInvoiceUpdated;

  const UpdateInvoiceModal({
    super.key,
    required this.invoice,
    required this.onInvoiceUpdated,
  });

  @override
  State<UpdateInvoiceModal> createState() => _UpdateInvoiceModalState();
}

class _UpdateInvoiceModalState extends State<UpdateInvoiceModal> {
  // final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late String _selectedStatus;
  late String _selectedPaymentStatus;

  final List<String> _invoiceStatuses = [
    'Draft',
    'Sent',
    'Paid',
    'Overdue',
    'Cancelled'
  ];
  final List<String> _paymentStatuses = [
    'Unpaid',
    'Paid',
    'Partial Payment',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.invoice.status;
    // _selectedPaymentStatus = widget.invoice.paymentStatus;
  }

  Future<void> _updateInvoice() async {
    // Update invoice status
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);

    if (_selectedStatus != widget.invoice.status) {

      final existingInvoice = widget.invoice.copyWith(
          status: _selectedStatus
      );
      await invoiceProvider.updateInvoice(existingInvoice);
      // await _dbHelper.updateOrderStatus(widget.invoice.id, _selectedStatus);
    }

    // Update payment status
    // if (_selectedPaymentStatus != widget.invoice.) {
    //   await _dbHelper.updateOrderPaymentStatus(widget.invoice.id, _selectedPaymentStatus);
    // }

    // Call the callback to refresh the parent screen
    widget.onInvoiceUpdated();

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Update Invoice Status',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Invoice Status Dropdown
            _buildDropdown(
              'Status',
              _selectedStatus,
              _invoiceStatuses,
                  (String? newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            // Payment Status Dropdown
            _buildDropdown(
              'Payment Status',
              _selectedPaymentStatus,
              _paymentStatuses,
                  (String? newValue) {
                setState(() {
                  _selectedPaymentStatus = newValue!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateInvoice,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('Update'),
        ),
      ],
    );
  }

  // Helper for dropdowns
  Widget _buildDropdown(
      String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
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
}