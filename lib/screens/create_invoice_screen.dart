// lib/screens/create_invoice_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/invoice_item.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/invoice_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

const _kPurple = Color(0xFF6200EE);
const _kBg = Color(0xFFF5F4F8);

class CreateInvoiceScreen extends StatefulWidget {
  final Customer? customer;
  final dynamic order; // Allow order parameter for compatibility
  const CreateInvoiceScreen({super.key, this.customer, this.order});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form state
  Customer? _selectedCustomer;
  String _invoiceNumber = "";
  DateTime? _issueDate;
  DateTime? _dueDate;
  String _notes = "";
  String _terms = "Payment due within 30 days";
  double _taxRate = 0.0;
  
  // Invoice items
  List<InvoiceItem> _items = [];
  
  late Future<List<Customer>> _customersFuture;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.customer;
    _customersFuture = _loadCustomers();
    _generateInvoiceNumber();
    _issueDate = DateTime.now();
    _dueDate = DateTime.now().add(const Duration(days: 30));
    
    // If order is provided but no customer, fetch customer from order
    if (widget.order != null && _selectedCustomer == null) {
      _fetchCustomerFromOrder();
    }
  }

  Future<void> _fetchCustomerFromOrder() async {
    try {
      final cp = Provider.of<CustomerProvider>(context, listen: false);
      await cp.fetchCustomers();
      // Don't auto-select, let user choose from dropdown
    } catch (e) {
      // Handle error gracefully
    }
  }

  String _generateInvoiceNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final random = (1000 + (now.millisecondsSinceEpoch % 9000)).toString();
    setState(() {
      _invoiceNumber = "INV-$year$month-$random";
    });
    return _invoiceNumber;
  }

  Future<List<Customer>> _loadCustomers() async {
    final cp = Provider.of<CustomerProvider>(context, listen: false);
    await cp.fetchCustomers();
    final customers = cp.customers;
    if (widget.customer != null) {
      try {
        _selectedCustomer = customers.firstWhere(
          (c) => c.id == widget.customer!.id,
        );
      } catch (_) {
        _selectedCustomer = null;
      }
    } else if (customers.isNotEmpty && _selectedCustomer == null) {
      setState(() => _selectedCustomer = customers.first);
    }
    return customers;
  }

  void _addItem() {
    setState(() {
      _items.add(InvoiceItem(
        invoiceId: '',
        description: '',
        quantity: 1,
        unitPrice: 0.0,
        amount: 0.0,
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateItem(int index, InvoiceItem item) {
    setState(() {
      _items[index] = item;
    });
  }

  double _calculateSubtotal() {
    return _items.fold(0.0, (sum, item) => sum + item.amount);
  }

  double _calculateTax() {
    return _calculateSubtotal() * (_taxRate / 100);
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _calculateTax();
  }

  Future<void> _selectIssueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kPurple,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _issueDate = picked);
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kPurple,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a customer", style: GoogleFonts.poppins()),
        ),
      );
      return;
    }

    final invoice = Invoice(
      customerId: _selectedCustomer!.id!,
      status: 'Draft',
      invoiceNumber: _invoiceNumber,
      issueDate: _issueDate,
      dueDate: _dueDate,
      notes: _notes,
      terms: _terms,
      subtotal: _calculateSubtotal(),
      tax: _calculateTax(),
      total: _calculateTotal(),
      items: _items,
      createdDate: DateTime.now().toIso8601String(),
    );

    try {
      await Provider.of<InvoiceProvider>(context, listen: false).addInvoice(invoice);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invoice created successfully", style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error creating invoice", style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          icon: const Icon(Icons.close, color: Colors.black87),
        ),
        title: Text(
          "Create Invoice",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveInvoice,
            child: Text(
              "Save",
              style: GoogleFonts.poppins(
                color: _kPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Customer>>(
        future: _customersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorState();
          }
          return _buildForm(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Error loading customers",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(List<Customer> customers) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Selection
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bill To",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Customer>(
                    value: _selectedCustomer,
                    decoration: _inputDecoration("Select Customer"),
                    items: customers.map((customer) {
                      return DropdownMenuItem<Customer>(
                        value: customer,
                        child: Text(
                          customer.name,
                          style: GoogleFonts.poppins(),
                        ),
                      );
                    }).toList(),
                    onChanged: (customer) {
                      setState(() => _selectedCustomer = customer);
                    },
                  ),
                  if (_selectedCustomer != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _selectedCustomer!.email ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Invoice Details
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Invoice Details",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _invoiceNumber,
                          decoration: _inputDecoration("Invoice Number"),
                          readOnly: true,
                          style: GoogleFonts.poppins(color: Colors.grey.shade600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectIssueDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(
                                text: _issueDate != null
                                    ? DateFormat('MMM dd, yyyy').format(_issueDate!)
                                    : '',
                              ),
                              decoration: _inputDecoration("Issue Date"),
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _selectDueDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(
                          text: _dueDate != null
                              ? DateFormat('MMM dd, yyyy').format(_dueDate!)
                              : '',
                        ),
                        decoration: _inputDecoration("Due Date"),
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Invoice Items
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Items",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(
                          "Add Item",
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._items.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _InvoiceItemRow(
                        item: entry.value,
                        index: entry.key,
                        onRemove: () => _removeItem(entry.key),
                        onUpdate: (item) => _updateItem(entry.key, item),
                      ),
                    );
                  }),
                  if (_items.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 32,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "No items added",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Add items to create invoice",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Summary
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Summary",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _taxRate.toString(),
                          decoration: _inputDecoration("Tax Rate (%)"),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _taxRate = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: _terms,
                          decoration: _inputDecoration("Terms"),
                          onChanged: (value) {
                            setState(() => _terms = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SummaryRow(
                    label: "Subtotal",
                    value: _calculateSubtotal(),
                    isBold: false,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: "Tax (${_taxRate.toStringAsFixed(1)}%)",
                    value: _calculateTax(),
                    isBold: false,
                  ),
                  const Divider(height: 24),
                  _SummaryRow(
                    label: "Total",
                    value: _calculateTotal(),
                    isBold: true,
                    color: _kPurple,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Notes
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notes",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: _notes,
                    decoration: _inputDecoration("Add any additional notes..."),
                    maxLines: 3,
                    onChanged: (value) {
                      setState(() => _notes = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kPurple),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InvoiceItemRow extends StatefulWidget {
  final InvoiceItem item;
  final int index;
  final VoidCallback onRemove;
  final Function(InvoiceItem) onUpdate;

  const _InvoiceItemRow({
    required this.item,
    required this.index,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  State<_InvoiceItemRow> createState() => _InvoiceItemRowState();
}

class _InvoiceItemRowState extends State<_InvoiceItemRow> {
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _unitPriceController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.item.description);
    _quantityController = TextEditingController(text: widget.item.quantity.toString());
    _unitPriceController = TextEditingController(text: widget.item.unitPrice.toStringAsFixed(2));
  }

  void _updateAmount(String? value) {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
    final amount = quantity * unitPrice;
    
    final updatedItem = InvoiceItem(
      id: widget.item.id,
      invoiceId: widget.item.invoiceId,
      description: _descriptionController.text,
      quantity: quantity,
      unitPrice: unitPrice,
      amount: amount,
    );
    
    widget.onUpdate(updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _kPurple),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: GoogleFonts.poppins(fontSize: 12),
                onChanged: (value) => _updateAmount(value),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  hintText: "Qty",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _kPurple),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(fontSize: 12),
                onChanged: (value) => _updateAmount(value),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: TextFormField(
                controller: _unitPriceController,
                decoration: InputDecoration(
                  hintText: "Price",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _kPurple),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(fontSize: 12),
                onChanged: (value) => _updateAmount(value),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: Text(
                "\$${widget.item.amount.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            IconButton(
              onPressed: widget.onRemove,
              icon: const Icon(Icons.close, size: 16, color: Colors.red),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;
  final Color? color;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black87,
          ),
        ),
        Text(
          "\$${value.toStringAsFixed(2)}",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
