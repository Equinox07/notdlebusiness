import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/customer.dart';

class CreateOrderScreen extends StatefulWidget {
  final List<Customer> customers;

  static const String tag = "create_order";
  const CreateOrderScreen({super.key, required this.customers});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  String _orderTitle = "";
  Customer? _selectedCustomer; // Use Customer model directly
  String _status = "Pending";
  String _paymentStatus = "Pending";
  String? _dueDate;
  String? _notes;

  @override
  void initState() {
    super.initState();
    if (widget.customers.isNotEmpty) {
      _selectedCustomer = widget.customers.first;
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dueDate = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Ensure a customer is selected
      if (_selectedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a customer")),
        );
        return;
      }

      // Logic to create the order goes here.
      print("Creating new order with the following data:");
      print("Order Title: $_orderTitle");
      print("Customer ID: ${_selectedCustomer!.id}");
      print("Client Name: ${_selectedCustomer!.name}");
      print("Status: $_status");
      print("Payment Status: $_paymentStatus");
      print("Due Date: $_dueDate");
      print("Notes: $_notes");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order Created Successfully!")),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create New Order",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Order Title",
                  border: OutlineInputBorder(),
                  hintText: "e.g., Wedding Dress",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter an order title";
                  }
                  return null;
                },
                onSaved: (value) => _orderTitle = value!,
              ),
              const SizedBox(height: 16),
              // Customer Dropdown Field
              DropdownButtonFormField<Customer>(
                decoration: const InputDecoration(
                  labelText: "Select Customer",
                  border: OutlineInputBorder(),
                ),
                value: _selectedCustomer,
                items:
                    widget.customers.map((customer) {
                      return DropdownMenuItem<Customer>(
                        value: customer,
                        child: Text(customer.name),
                      );
                    }).toList(),
                onChanged: (customer) {
                  setState(() {
                    _selectedCustomer = customer;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Please select a customer";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
                value: _status,
                items:
                    ["Pending", "In Progress", "Completed"]
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Payment Status",
                  border: OutlineInputBorder(),
                ),
                value: _paymentStatus,
                items:
                    ["Pending", "Partial", "Full"]
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Date Picker Field
              TextFormField(
                readOnly: true,
                controller: TextEditingController(text: _dueDate),
                decoration: InputDecoration(
                  labelText: "Due Date",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDueDate(context),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a due date";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Notes (Optional)",
                  border: OutlineInputBorder(),
                  hintText: "Add any specific details here...",
                ),
                maxLines: 3,
                onSaved: (value) => _notes = value,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Create Order",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
