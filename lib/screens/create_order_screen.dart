// lib/screens/create_order_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/dashboard_provider.dart';
import 'package:notdle/providers/invoice_provider.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:notdle/screens/invoice_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  static const String tag = "create_order";

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form state variables
  String _orderTitle = "";
  Customer? _selectedCustomer;
  String _status = "Pending";
  String _paymentStatus = "Unpaid"; // Changed default to be more descriptive
  DateTime? _dueDate;
  String? _notes;
  String? _paymentAmount;

  // Using a FutureBuilder for cleaner state management
  late Future<List<Customer>> _customersFuture;

  // Define statuses as constants to prevent typos
  static const List<String> _orderStatuses = ["Pending", "In Progress", "Completed", "Cancelled"];
  static const List<String> _paymentStatuses = ["Unpaid", "Partial", "Paid"];

  @override
  void initState() {
    super.initState();
    _customersFuture = _loadCustomers();
  }

  Future<List<Customer>> _loadCustomers() async {
    // This now returns the list for the FutureBuilder
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    await customerProvider.fetchCustomers();
    final customers = customerProvider.customers;

    if (customers.isNotEmpty && _selectedCustomer == null) {
      // Pre-select the first customer
      setState(() {
        _selectedCustomer = customers.first;
      });
    }
    return customers;
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a customer", style: GoogleFonts.poppins())),
      );
      return;
    }

    final newOrder = Order(
      id: const Uuid().v4(),
      title: _orderTitle,
      customerId: _selectedCustomer!.id!,
      status: _status,
      paymentStatus: _paymentStatus,
      paymentAmount: double.tryParse(_paymentAmount ?? '0'),
      dueDate: _dueDate != null ? DateFormat('yyyy-MM-dd').format(_dueDate!) : null,
      notes: _notes,
      createdDate: DateTime.now().toIso8601String(),
    );

    await Provider.of<OrderProvider>(context, listen: false).addOrder(newOrder);
    Provider.of<DashBoardProvider>(context, listen: false).fetchCounts();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Order Created", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text(
            "Would you like to generate an invoice for this order now?",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to orders screen
              },
              child: Text("Later", style: GoogleFonts.poppins(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog before navigating
                _generateInvoice(newOrder);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Create Invoice", style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
      },
    );
  }

  void _generateInvoice(Order newOrder) async {
    final newInvoice = Invoice(
      id: const Uuid().v4(),
      title: 'Invoice for ${newOrder.title}',
      customerId: newOrder.customerId,
      status: 'Pending', // Invoices should start as Pending/Draft
      totalAmount: newOrder.paymentAmount ?? 0.0,
      date: DateTime.now(),
      // dueDate: _dueDate ?? DateTime.now().add(const Duration(days: 14)),
      orderId: newOrder.id,
    );

    await Provider.of<InvoiceProvider>(context, listen: false).addInvoice(newInvoice);

    if (!mounted) return;

    // Navigate to the new invoice, replacing the create screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => InvoiceDetailsScreen(invoice: newInvoice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Create New Order", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: FutureBuilder<List<Customer>>(
        future: _customersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_alt_outlined, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      "No Customers Found",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You must add a customer before you can create an order.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          final customers = snapshot.data!;
          return _buildForm(customers);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitForm,
        backgroundColor: Colors.indigo.shade600,
        label: Text("Create Order", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
    );
  }

  // --- Builder Widgets ---

  Widget _buildForm(List<Customer> customers) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Order Details", icon: Icons.shopping_bag_outlined),
              const SizedBox(height: 12),
              _buildCard(
                children: [
                  _buildTextFormField(
                    label: "Order Title",
                    hint: "e.g., Custom Wedding Dress",
                    onSaved: (value) => _orderTitle = value!,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownFormField<Customer>(
                    label: "Select Customer",
                    value: _selectedCustomer,
                    items: customers.map((customer) => DropdownMenuItem(
                      value: customer,
                      child: Text(customer.name, style: GoogleFonts.poppins()),
                    )).toList(),
                    onChanged: (customer) => setState(() => _selectedCustomer = customer),
                    validator: (value) => value == null ? "Please select a customer" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDatePickerField(),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionHeader("Status & Payment", icon: Icons.receipt_long_outlined),
              const SizedBox(height: 12),
              _buildCard(
                children: [
                  _buildDropdownFormField<String>(
                    label: "Order Status",
                    value: _status,
                    items: _orderStatuses.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status, style: GoogleFonts.poppins()),
                    )).toList(),
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownFormField<String>(
                    label: "Payment Status",
                    value: _paymentStatus,
                    items: _paymentStatuses.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status, style: GoogleFonts.poppins()),
                    )).toList(),
                    onChanged: (value) => setState(() => _paymentStatus = value!),
                  ),
                  if (_paymentStatus != "Unpaid") ...[
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      label: "Amount Paid",
                      hint: "e.g., 250.00",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onSaved: (value) => _paymentAmount = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Amount is required";
                        if (double.tryParse(value) == null) return "Please enter a valid number";
                        return null;
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionHeader("Additional Notes", icon: Icons.description_outlined),
              const SizedBox(height: 12),
              _buildCard(
                children: [
                  _buildTextFormField(
                    label: "Notes (Optional)",
                    hint: "Add any specific details or requests here...",
                    maxLines: 4,
                    onSaved: (value) => _notes = value,
                    validator: (value) => null, // Optional field
                  ),
                ],
              ),
              const SizedBox(height: 100), // Space for the FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo.shade600, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
        ),
      ],
    );
  }

  // Redesigned "Classic" Card
  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  TextFormField _buildTextFormField({
    required String label,
    String? hint,
    int? maxLines = 1,
    required FormFieldSetter<String?> onSaved,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade600, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      maxLines: maxLines,
      onSaved: onSaved,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) return "This field is required";
        return null;
      },
    );
  }

  DropdownButtonFormField<T> _buildDropdownFormField<T>({
    required String label,
    T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    FormFieldValidator<T>? validator,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade600, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      value: value,
      style: GoogleFonts.poppins(color: Colors.black87),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDatePickerField() {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: _dueDate != null ? DateFormat('MMMM d, yyyy').format(_dueDate!) : '',
      ),
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: "Due Date",
        hintText: "Select a date",
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade600, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: Icon(Icons.calendar_today_outlined, color: Colors.indigo.shade600),
      ),
      onTap: () => _selectDueDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) return "Please select a due date";
        return null;
      },
    );
  }
}