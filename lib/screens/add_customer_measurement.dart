import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/measurement_provider.dart';
import 'package:provider/provider.dart';

// These are placeholder models and services.
// Make sure to use your actual file paths.

class AddCustomerMeasurementScreen extends StatefulWidget {
  final Customer customer;

  static const String tag = "customer_measurement";

  const AddCustomerMeasurementScreen({super.key, required this.customer});

  @override
  State<AddCustomerMeasurementScreen> createState() =>
      _CustomerMeasurementScreenState();
}

class _CustomerMeasurementScreenState
    extends State<AddCustomerMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

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
    "Sleeve Measurement",
    "Trouser Waist",
    "Thigh",
    "Hip",
    "Knee",
    "Base",
    "Cloth Type",
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

  late final List<String> _fields;

  // Dropdown options
  final List<String> _measurementType = [
    "None",
    "Shirt",
    "Blouse",
    "Long Sleeves",
    "Short Sleeves"
        "Short",
    "Trousers",
    "Skirt",
    "Full Dress",
  ];
  final String _selectedMeasureType = "None";

  final List<String> _sleeveOptions = ["None", "Short", "3 Quarters", "Full"];
  String _selectedSleeve = "None";

  final List<String> _clothOptions = ["None", "Trouser", "Skirt", "Full Dress"];
  String _selectedCloth = "None";

  @override
  void initState() {
    debugPrint("*****onCustomerMeasurement*******");
    super.initState();
    _fields =
        widget.customer.gender.toLowerCase() == "female"
            ? _femaleFields
            : _maleFields;

    for (var field in _fields) {
      _controllers[field] = TextEditingController();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
        widget.customer.imagePath = picked.path;
      });
      // await DatabaseHelper.instance.updateCustomer(widget.customer);

      if(mounted){
        await Provider.of<CustomerProvider>(context, listen: false).updateCustomer(widget.customer);
      }
    }
  }

  Future<void> _saveMeasurement() async {
    // Check if at least one measurement field has a value
    final bool hasMeasurement = _controllers.values.any(
      (controller) => controller.text.isNotEmpty,
    );

    if (!hasMeasurement) {
      // Show a snackbar or an alert to the user
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in at least one measurement field."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final values = <String, double>{};
    for (var entry in _controllers.entries) {
      final val = double.tryParse(entry.value.text);
      if (val != null) {
        values[entry.key] = val;
      }
    }

    if (widget.customer.id == null) {
      throw Exception("Customer must be saved before adding measurement.");
    }

    if (widget.customer.gender.toLowerCase() == "female") {
      values["Sleeve Length"] =
          _sleeveOptions.indexOf(_selectedSleeve).toDouble();
      values["Cloth Type"] = _clothOptions.indexOf(_selectedCloth).toDouble();
    }

    final measurement = Measurement(
      customerId: widget.customer.id!,
      measurementValues: values,
      createdDate: DateTime.now(),
    );

    // final saved = await DatabaseHelper.instance.insertMeasurement(measurement);
    final savedCustomer = await Provider.of<MeasurementProvider>(context, listen: false).addMeasurement(measurement);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Measurement saved")));
    AppNavigator.toMeasurement2();
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

  Widget _buildFieldWidget(String field) {
    // return _MeasurementTypeDropdownField(
    //   measurementTypeOptions: [],
    //   selectedType: _selectedMeasureType,
    //   onChanged: (val) => debugPrint("val"),
    // );

    if (widget.customer.gender.toLowerCase() == "female") {
      switch (field) {
        case "Sleeve Length":
          return _SleeveDropdownField(
            selectedSleeve: _selectedSleeve,
            sleeveOptions: _sleeveOptions,
            onChanged: (val) => setState(() => _selectedSleeve = val!),
          );
        case "Cloth Type":
          return _ClothDropdownAndTextField(
            controller: _controllers["Cloth Type"]!,
            selectedCloth: _selectedCloth,
            clothOptions: _clothOptions,
            onChanged: (val) => setState(() => _selectedCloth = val!),
          );
      }
    }
    return TextFormField(
      controller: _controllers[field],
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator:
          (value) => value == null || value.isEmpty ? "Enter $field" : null,
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // _MeasurementTypeDropdownField(
            //   measurementTypeOptions: _measurementType,
            //   selectedType: _selectedMeasureType,
            //   onChanged: (val) => debugPrint(val),
            // ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _fields.length,
                  itemBuilder: (context, index) {
                    final field = _fields[index];
                    return _buildFieldWidget(field);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                ),
              ),
            ),
          ],
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

class _MeasurementTypeDropdownField extends StatelessWidget {
  final String selectedType;
  final List<String> measurementTypeOptions;
  final ValueChanged<String?> onChanged;

  const _MeasurementTypeDropdownField({
    required this.selectedType,
    required this.measurementTypeOptions,
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
        value: selectedType,
        decoration: InputDecoration(
          labelText: "Measure For",
          labelStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          border: InputBorder.none,
        ),
        items:
            measurementTypeOptions.map((option) {
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

class _SleeveDropdownField extends StatelessWidget {
  final String selectedSleeve;
  final List<String> sleeveOptions;
  final ValueChanged<String?> onChanged;

  const _SleeveDropdownField({
    required this.selectedSleeve,
    required this.sleeveOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedSleeve,
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
        onChanged: onChanged,
      ),
    );
  }
}

class _ClothDropdownAndTextField extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCloth;
  final List<String> clothOptions;
  final ValueChanged<String?> onChanged;

  const _ClothDropdownAndTextField({
    required this.controller,
    required this.selectedCloth,
    required this.clothOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
            value: selectedCloth,
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
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
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
}
