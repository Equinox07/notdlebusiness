import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/db/database_helper.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/screens/add_measurement_screen.dart';
import 'package:notdle/screens/orders_screen.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  static const String tag = "add_customer";

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedGender = "Other";

  Future<Customer?> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return null;

    if (_selectedGender == "Other") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gender Cannot be Other",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    final newCustomer = Customer(
      name: _nameController.text.trim(),
      gender: _selectedGender,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      lastVisit: DateTime.now(),
      createdDate: DateTime.now(),
    );

    final savedCustomer = await DatabaseHelper.instance.insertCustomer(
      newCustomer,
    );
    return savedCustomer;


  }

  // void _saveCustomer({String? action}) {
  //   if (_formKey.currentState!.validate()) {
  //     final customer = Customer(
  //       id: DateTime.now().millisecondsSinceEpoch.toString(),
  //       name: _nameController.text,
  //       phone: _phoneController.text,
  //       email: _emailController.text,
  //       gender: _selectedGender,
  //       address: _addressController.text,
  //       orders: 0,
  //       lastVisit: DateTime.now(),
  //       createdDate: DateTime.now(),
  //     );

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Customer saved (${action ?? 'normal'})")),
  //     );

  //     if (action == "measurement") {
  //       // Navigate to measurement screen
  //     } else if (action == "order") {
  //       // Navigate to order screen
  //     } else {
  //       Navigator.pop(context, customer);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Customer",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          TextButton(
            onPressed: () async {
              final saved = await _saveCustomer();
              if (saved != null) Navigator.pop(context, saved);
            },
            child: Text(
              "Save",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Avatar Placeholder
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.indigo.shade100,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.indigo.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator:
                    (val) => val == null || val.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? "Enter phone number"
                            : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator:
                    (val) =>
                        val == null || !val.contains("@")
                            ? "Enter valid email"
                            : null,
              ),
              const SizedBox(height: 16),

              // Gender Dropdown
              _GenderDropdownField(
                genderOptions: ["Male", "Female", "Other"],
                selectedGender: _selectedGender,
                onChanged: (val) {
                  setState(() {
                    _selectedGender = val!;
                  });
                },
              ),
              // DropdownButtonFormField<String>(
              //   value: _selectedGender,
              //   hint: const Text("Select Gender"),
              //   items:
              //       ["Male", "Female", "Other"].map((gender) {
              //         return DropdownMenuItem(
              //           value: gender,
              //           child: Text(gender),
              //         );
              //       }).toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedGender = value!;
              //     });
              //   },
              //   validator:
              //       (value) => value == null ? "Please select a gender" : null,
              // ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      // ✅ Fixed bottom buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final saved = await _saveCustomer();
                  if (saved != null) {
                    AppNavigator.toMeasurement2(customer: saved);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => AddMeasurementScreen(customer: saved),
                    //   ),
                    // );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.straighten, color: Colors.white),
                label: Text(
                  "Save & Take Measurement",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // const SizedBox(height: 12),
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton.icon(
            //     onPressed: () async {
            //       final saved = await _saveCustomer();
            //       if (saved != null) {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(builder: (_) => OrdersScreen()),
            //         );
            //       }
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.indigo,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       padding: const EdgeInsets.symmetric(vertical: 16),
            //     ),
            //     icon: const Icon(
            //       Icons.shopping_bag_outlined,
            //       color: Colors.white,
            //     ),
            //     label: Text(
            //       "Save & Create Order",
            //       style: GoogleFonts.poppins(
            //         fontSize: 15,
            //         fontWeight: FontWeight.w600,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _GenderDropdownField extends StatelessWidget {
  final String selectedGender;
  final List<String> genderOptions;
  final ValueChanged<String?> onChanged;

  const _GenderDropdownField({
    required this.selectedGender,
    required this.genderOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        // borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: InputDecoration(
          labelText: "Gender",
          labelStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          border: InputBorder.none,
        ),
        items:
            genderOptions.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option, style: GoogleFonts.poppins(fontSize: 16)),
              );
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
