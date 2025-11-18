// lib/screens/create_invoice_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/invoice_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final Order order;
  const CreateInvoiceScreen({super.key, required this.order});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  // final dbHelper = DatabaseHelper.instance;

  late String _invoiceTitle;
  late String _customerName;
  late double _totalAmount;
  String _paymentStatus = 'Pending';
  String? _notes;

  @override
  void initState() {
    super.initState();
    _invoiceTitle = 'Invoice for ${widget.order.title}';
    _totalAmount = widget.order.paymentAmount ?? 0.0;
    _paymentStatus = widget.order.paymentStatus;
    _notes = widget.order.notes;
    // Fetch customer name from the database based on customerId
    _fetchCustomerName();
  }

  Future<void> _fetchCustomerName() async {
    final customer = await Provider.of<CustomerProvider>(
      context,
      listen: false,
    ).getCustomerById(
      widget.order.customerId,
    ); //await dbHelper.fetchCustomerById(widget.order.customerId);
    setState(() {
      _customerName = customer!.name;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Get the current date and format it as an ISO 8601 string
      final String currentDateTime = DateTime.now().toIso8601String();
      // Create and save the new Invoice object to the database
      final newInvoice = Invoice(
        id: Uuid().v4(),
        title: _invoiceTitle,
        customerId: widget.order.customerId,
        status: _paymentStatus,
        totalAmount: _totalAmount,
        date: DateTime.now(),
        orderId: widget.order.id,
      );

      // await dbHelper.insertInvoice(newInvoice);
      await Provider.of<InvoiceProvider>(
        context,
        listen: false,
      ).addInvoice(newInvoice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Invoice Created Successfully!",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Create Invoice",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Invoice Details", icon: Icons.receipt),
              const SizedBox(height: 12),
              _buildCard(
                children: [
                  _buildTextFormField(
                    label: "Invoice Title",
                    initialValue: _invoiceTitle,
                    onSaved: (value) => _invoiceTitle = value!,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    label: "Customer Name",
                    initialValue: _customerName,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    label: "Total Amount",
                    initialValue: _totalAmount.toStringAsFixed(2),
                    onSaved:
                        (value) =>
                            _totalAmount = double.tryParse(value!) ?? 0.0,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownFormField<String>(
                    label: "Payment Status",
                    value: _paymentStatus,
                    items:
                        ["Pending", "Partial", "Full", "Paid"]
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
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionHeader("Notes", icon: Icons.description_outlined),
              const SizedBox(height: 12),
              _buildCard(
                children: [
                  _buildTextFormField(
                    label: "Notes",
                    initialValue: _notes,
                    onSaved: (value) => _notes = value,
                    maxLines: 3,
                    validator: (value) => null,
                  ),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitForm,
        backgroundColor: Colors.indigo.shade600,
        label: Text(
          "Generate Invoice",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.description, color: Colors.white),
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
    String? initialValue,
    int? maxLines = 1,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      enabled: enabled,
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
}
