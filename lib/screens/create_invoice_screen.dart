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

const _kPurple = Color(0xFF6200EE);
const _kBg = Color(0xFFFBFBFB);

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
  double _taxRate = 8.0;

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
      _items.add(
        InvoiceItem(
          invoiceId: '',
          description: '',
          quantity: 1,
          unitPrice: 0.0,
          amount: 0.0,
        ),
      );
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
      builder:
          (context, child) => Theme(
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
      builder:
          (context, child) => Theme(
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please fix the validation errors",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select a customer",
            style: GoogleFonts.poppins(),
          ),
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
      await Provider.of<InvoiceProvider>(
        context,
        listen: false,
      ).addInvoice(invoice);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Invoice created successfully",
            style: GoogleFonts.poppins(),
          ),
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
          "New Invoice",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveInvoice,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(right: 16),
            ),
            child: Text(
              "Save",
              style: GoogleFonts.poppins(
                color: _kPurple,
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _saveInvoice,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPurple,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              "Generate Invoice",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
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
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "CLIENT DETAILS",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Handle adding new client
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.person_add, color: _kPurple, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "New Client",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _kPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<Customer>(
                    value: _selectedCustomer,
                    decoration: _inputDecoration("Select Client").copyWith(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    icon: const Icon(
                      Icons.keyboard_double_arrow_down,
                      color: Colors.blueGrey,
                      size: 18,
                    ),
                    items:
                        customers.map((customer) {
                          return DropdownMenuItem<Customer>(
                            value: customer,
                            child: Text(
                              customer.name,
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (customer) {
                      setState(() => _selectedCustomer = customer);
                    },
                  ),
                  if (_selectedCustomer != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "124 Fashion Ave, New York, NY", // Mocking the location string to match design
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.blueGrey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectIssueDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(
                                text:
                                    _issueDate != null
                                        ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(_issueDate!)
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
                          text:
                              _dueDate != null
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

            // Itemized Services
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
              child: Text(
                "ITEMIZED SERVICES",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ..._items.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _SectionCard(
                  child: _InvoiceItemRow(
                    item: entry.value,
                    index: entry.key,
                    onRemove: () => _removeItem(entry.key),
                    onUpdate: (item) => _updateItem(entry.key, item),
                  ),
                ),
              );
            }),
            if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
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
                    ],
                  ),
                ),
              ),
            GestureDetector(
              onTap: _addItem,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF7FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _kPurple.withOpacity(0.3),
                    width: 1.5,
                  ), // Simulating dashed border
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle, color: _kPurple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Add Item",
                      style: GoogleFonts.poppins(
                        color: _kPurple,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Summary
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subtotal",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                      ),
                      Text(
                        "\$${_calculateSubtotal().toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Tax",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E5F5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${_taxRate.toStringAsFixed(0)}%",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: _kPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "\$${_calculateTax().toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "\$${_calculateTotal().toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                    ],
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
      hintStyle: GoogleFonts.poppins(
        color: Colors.blueGrey.shade300,
        fontSize: 13,
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _kPurple, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
  late TextEditingController _detailsController;
  late TextEditingController _quantityController;
  late TextEditingController _unitPriceController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.item.description,
    );
    _detailsController = TextEditingController();
    _quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _unitPriceController = TextEditingController(
      text: widget.item.unitPrice.toStringAsFixed(2),
    );
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SERVICE TYPE",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    onChanged: (value) => _updateAmount(value),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PRICE",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _unitPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: "\$ ",
                      prefixStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: (value) => _updateAmount(value),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 22, left: 4),
              child: IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.redAccent,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "DESCRIPTION",
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade400,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _detailsController,
          maxLines: 2,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }
}
