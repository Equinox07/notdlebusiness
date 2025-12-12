import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/measurement_provider.dart';
import 'package:provider/provider.dart';

class AddMeasurementScreen extends StatefulWidget {
  final Customer customer;

  static const String tag = "add_measurement";

  const AddMeasurementScreen({super.key, required this.customer});

  @override
  State<AddMeasurementScreen> createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends State<AddMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

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
      // await DatabaseHelper.instance.updateCustomer(widget.customer);
      if(mounted){
        await Provider.of<CustomerProvider>(context, listen: false).updateCustomer(widget.customer);
      }
    }
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
    "Sleeve Length/Short/3 Quarters/Full", // dropdown
    "Sleeve Measurement",
    "Trouser Waist",
    "Thigh",
    "Hip",
    "Knee",
    "Base",
    "Cloth", // dropdown
  ];

  final List<String> _maleFields = [
    "Chest",
    "Across Back",
    "Sleeve",
    "Cuff",
    "Shirt",
    "Waist",
    "Thigh",
    "Knee",
    "Base",
    "Trouser",
    "Chin",
  ];

  late List<String> _fields;

  // Dropdown options
  final List<String> sleeveOptions = ["None", "Short", "3 Quarters", "Full"];
  String _selectedSleeve = "None";

  final List<String> clothOptions = ["None", "Trouser", "Skirt", "Full Dress"];
  String _selectedCloth = "None";

  @override
  void initState() {
    super.initState();
    _fields =
        widget.customer.gender.toLowerCase() == "female"
            ? _femaleFields
            : _maleFields;

    for (var field in _fields) {
      _controllers[field] = TextEditingController();
    }
  }

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validate()) return;

    final values = <String, double>{};
    for (var entry in _controllers.entries) {
      final val = double.tryParse(entry.value.text);
      if (val != null) {
        values[entry.key] = val; // only store non-empty values
      }
    }

    if (widget.customer.id == null) {
      throw Exception("Customer must be saved before adding measurement.");
    }

    if (widget.customer.gender.toLowerCase() == "female") {
      values["SleeveLength"] =
          sleeveOptions.indexOf(_selectedSleeve).toDouble();
      values["ClothType"] = clothOptions.indexOf(_selectedCloth).toDouble();
    }

    final measurement = Measurement(
      customerId: widget.customer.id!,
      measurementValues: values,
      createdDate: DateTime.now(), name: '',
    );

    // final saved = await DatabaseHelper.instance.insertMeasurement(measurement);
    final saved = await Provider.of<MeasurementProvider>(context, listen: false).addMeasurement(measurement);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Measurement saved")));
    Navigator.pop(context, saved);
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

  Widget buildSleeveField() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedSleeve,
        decoration: InputDecoration(
          labelText: "Sleeve Length",
          labelStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
          border: InputBorder.none,
        ),
        items:
            sleeveOptions.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option, style: GoogleFonts.poppins(fontSize: 16)),
              );
            }).toList(),
        onChanged: (val) {
          if (val != null) setState(() => _selectedSleeve = val);
        },
      ),
    );
  }

  Widget buildClothField() {
    return Row(
      children: [
        // Dropdown
        Container(
          width: 150,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: _selectedCloth,
            isExpanded: true,
            underline: const SizedBox(),
            items:
                clothOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(
                      option,
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  );
                }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCloth = val);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _controllers["Cloth"]!,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: "Measurement",
              labelStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 16,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            validator:
                (value) =>
                    value == null || value.isEmpty ? "Enter measurement" : null,
          ),
        ),
      ],
    );
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
    final isTablet = MediaQuery.of(context).size.width > 600;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
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

              if (field == "Sleeve Length/Short/3 Quarters/Full" &&
                  widget.customer.gender.toLowerCase() == "female") {
                return buildSleeveField();
              }

              if (field == "Cloth" &&
                  widget.customer.gender.toLowerCase() == "female") {
                return buildClothField();
              }

              return SizedBox(
                width: double.infinity,
                child: TextFormField(
                  controller: _controllers[field],
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: field,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? "Enter $field"
                              : null,
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 16),
          ),
        ),
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
