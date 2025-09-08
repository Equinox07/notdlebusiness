// lib/screens/create_order_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/db/database_helper.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/screens/invoice_details_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  static const String tag = "create_order";

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper.instance;

  String _orderTitle = "";
  Customer? _selectedCustomer;
  String _status = "Pending";
  String _paymentStatus = "Pending";
  String? _dueDate;
  String? _notes;
  String? _paymentAmount;

  late Future<List<Customer>> _customersFuture;

  @override
  void initState() {
    super.initState();
    _customersFuture = dbHelper.fetchCustomers();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
    if (picked != null) {
      setState(() {
        _dueDate = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
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

      // Get the current date and format it as an ISO 8601 string
      final String currentDateTime = DateTime.now().toIso8601String();

      final newOrder = Order(
        title: _orderTitle,
        customerId: _selectedCustomer!.id!,
        status: _status,
        paymentStatus: _paymentStatus,
        paymentAmount: double.tryParse(_paymentAmount ?? ''),
        dueDate: _dueDate,
        notes: _notes,
        createdDate: currentDateTime
      );

      await dbHelper.insertOrder(newOrder);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Order Created",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "Your order has been created successfully. Would you like to generate an invoice now?",
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Later",
                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _generateInvoice(newOrder);
                  // Navigator.of(context).pop();
                  // Navigator.of(context).pop();
                  // In a real app, you would navigate to the invoice screen
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => CreateInvoiceScreen(order: newOrder),
                  //   ),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Create Invoice",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      );
    }
  }

  void _generateInvoice(Order newOrder) async {
    if (_paymentStatus != 'Pending' && _paymentAmount != null) {
      final newInvoice = Invoice(
        title: 'Invoice for $_orderTitle',
        customerId: _selectedCustomer!.id!,
        status: _paymentStatus,
        totalAmount: double.tryParse(_paymentAmount!) ?? 0.0,
        date: DateTime.now(),
        orderId: newOrder.id,
      );

      await dbHelper.insertInvoice(newInvoice);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order and Invoice created successfully!'),
        ),
      );

      // Navigate to the InvoiceDetailsScreen, passing the new invoice object
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => InvoiceDetailsScreen(invoice: newInvoice),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Create New Order",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Customer>>(
        future: _customersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error fetching customers: ${snapshot.error}",
                style: GoogleFonts.poppins(),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "No customers found. Please add a customer first.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            );
          }

          final customers = snapshot.data!;
          // Set the first customer as the default if none is selected
          _selectedCustomer ??= customers.first;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      "Order Details",
                      icon: Icons.shopping_bag_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildTextFormField(
                          label: "Order Title",
                          hint: "e.g., Wedding Dress",
                          onSaved: (value) => _orderTitle = value!,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownFormField<Customer>(
                          label: "Select Customer",
                          value: _selectedCustomer,
                          items:
                              customers
                                  .map(
                                    (customer) => DropdownMenuItem(
                                      value: customer,
                                      child: Text(
                                        customer.name,
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (customer) {
                            setState(() => _selectedCustomer = customer);
                          },
                          validator:
                              (value) =>
                                  value == null
                                      ? "Please select a customer"
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        _buildDatePickerField(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      "Status & Payment",
                      icon: Icons.receipt_long,
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildDropdownFormField<String>(
                          label: "Status",
                          value: _status,
                          items:
                              ["Pending", "In Progress", "Completed"]
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(
                                        status,
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) => setState(() => _status = value!),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownFormField<String>(
                          label: "Payment Status",
                          value: _paymentStatus,
                          items:
                              ["Pending", "Partial", "Full"]
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(
                                        status,
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _paymentStatus = value!;
                            });
                          },
                        ),
                        if (_paymentStatus != "Pending") ...[
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            label: "Amount Paid",
                            hint: "e.g., 250.00",
                            keyboardType: TextInputType.number,
                            onSaved: (value) => _paymentAmount = value!,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      "Notes",
                      icon: Icons.description_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildCard(
                      children: [
                        _buildTextFormField(
                          label: "Notes (Optional)",
                          hint: "Add any specific details here...",
                          maxLines: 3,
                          onSaved: (value) => _notes = value,
                          validator: (value) => null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitForm,
        backgroundColor: Colors.indigo.shade600,
        label: Text(
          "Create Order",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
    );
  }

  // Helper Widgets (Unchanged)
  Widget _buildSectionHeader(String title, {required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo.shade600),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: children),
      ),
    );
  }

  TextFormField _buildTextFormField({
    required String label,
    String? hint,
    int? maxLines = 1,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(),
        hintStyle: GoogleFonts.poppins(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade600, width: 2.0),
        ),
      ),
      maxLines: maxLines,
      onSaved: onSaved,
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return "This field is required";
            }
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
        labelStyle: GoogleFonts.poppins(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade600, width: 2.0),
        ),
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
      controller: TextEditingController(text: _dueDate),
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: "Due Date",
        labelStyle: GoogleFonts.poppins(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade600, width: 2.0),
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today, color: Colors.indigo.shade600),
          onPressed: () => _selectDueDate(context),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select a due date";
        }
        return null;
      },
    );
  }
}
