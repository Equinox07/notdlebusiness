import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notdle/db/database_helper.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/measurement.dart';

class MeasurementScreen extends StatefulWidget {
  final Customer customer;

  const MeasurementScreen({super.key, required this.customer});

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  late Measurement measurement;

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
        widget.customer.imagePath = picked.path;
      });

      // ✅ Save update to SQLite
      await DatabaseHelper.instance.updateCustomer(widget.customer);
    }
  }

  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.indigo),
                title: Text("Take Photo", style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: Text(
                  "Choose from Gallery",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  final List<String> _femaleFields = [
    "Bust",
    "Niple to Niple",
    "Under Bust",
    "Waist",
    "Shoulder to Shoulder",
    "Full Blouse Length",
    "Across Back",
    "Around Arm",
    "Sleeve Length",
    "Trouser Waist",
    "Thigh",
    "Hip",
    "Knee",
    "Base",
    "Trouser/Skirt/Full Dress",
  ];

  final List<String> _maleFields = [
    "Chest",
    "Across Back",
    "Sleeve",
    "Cuff",
    "Shirt/Kaftan",
    "Waist",
    "Thigh",
    "Knee",
    "Base",
    "Trouser",
    "Chin",
  ];

  List<String> get _fields =>
      widget.customer.gender.toLowerCase() == "female"
          ? _femaleFields
          : _maleFields;

  @override
  void initState() {
    super.initState();
    super.initState();
    for (var field in _fields) {
      _controllers[field] = TextEditingController();
    }
  }

  Future<void> _saveMeasurement() async {
    final values = <String, double>{};
    for (var entry in _controllers.entries) {
      final val = double.tryParse(entry.value.text);
      if (val != null) {
        values[entry.key] = val;
      }
    }

    final measurement = Measurement(
      customerId: widget.customer.id,
      values: values,
      createdDate: DateTime.now(),
    );

    await DatabaseHelper.instance.insertMeasurement(measurement);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Measurement saved")));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = _controllers.keys.toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              // Profile avatar with upload
              GestureDetector(
                onTap: _showImageSourceActionSheet,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.indigo.shade100,
                  backgroundImage:
                      _profileImage != null
                          ? FileImage(_profileImage!)
                          : (widget.customer.imagePath != null
                              ? FileImage(File(widget.customer.imagePath!))
                              : null),
                  child:
                      (_profileImage == null &&
                              widget.customer.imagePath == null)
                          ? Text(
                            widget.customer.name.isNotEmpty
                                ? widget.customer.name[0].toUpperCase()
                                : "?",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          )
                          : null,
                ),
              ),
              const SizedBox(width: 12),

              // Name + subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customer.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "${widget.customer.gender} • ${widget.customer.phone}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        body: Form(
          key: _formKey,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: fields.length,
            itemBuilder: (context, index) {
              final field = fields[index];
              return TextFormField(
                controller: _controllers[field],
                decoration: InputDecoration(
                  labelText: field,
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Enter $field" : null,
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 16),
          ),
        ),

        // ✅ Save button pinned at bottom
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
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveMeasurement,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                "Save Measurements",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
