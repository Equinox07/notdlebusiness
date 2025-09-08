// lib/widgets/update_order_modal.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/db/database_helper.dart';
import 'package:notdle/models/order.dart';

class UpdateOrderModal extends StatefulWidget {
  final Order order;
  final Function() onOrderUpdated;

  const UpdateOrderModal({
    super.key,
    required this.order,
    required this.onOrderUpdated,
  });

  @override
  State<UpdateOrderModal> createState() => _UpdateOrderModalState();
}

class _UpdateOrderModalState extends State<UpdateOrderModal> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
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
    'Pending',
    'Paid',
    'Refunded',
    'Partial',
    'Completed'
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
    _selectedPaymentStatus = widget.order.paymentStatus;
  }

  Future<void> _updateOrder() async {
    // Update order status if it has changed
    if (_selectedStatus != widget.order.status) {
      await _dbHelper.updateOrderStatus(widget.order.id, _selectedStatus);
    }

    // Update payment status if it has changed
    if (_selectedPaymentStatus != widget.order.paymentStatus) {
      await _dbHelper.updateOrderPaymentStatus(widget.order.id, _selectedPaymentStatus);
    }

    // Call the callback to refresh the parent screen
    widget.onOrderUpdated();

    // Close the modal
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Update Order Status',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDropdown(
              'Order Status',
              _selectedStatus,
              _orderStatuses,
                  (String? newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
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
          onPressed: _updateOrder,
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