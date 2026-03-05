import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/enum/measurement_category.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/models/measurement_field.dart';
import 'package:notdle/models/image_owner_types.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/image_provider.dart';
import 'package:notdle/providers/measurement_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:notdle/widgets/custom_app_bar.dart';

class NewMeasurementScreen extends StatefulWidget {
  final Customer customer;
  static const String tag = "new_measurement_screen";

  const NewMeasurementScreen({super.key, required this.customer});

  @override
  State<NewMeasurementScreen> createState() => _NewMeasurementScreenState();
}

class _NewMeasurementScreenState extends State<NewMeasurementScreen> {
  bool _isMetric = false;
  final _nameController = TextEditingController();

  // Dynamic fields from MeasurementField model
  late List<MeasurementField> _fields;
  late Map<String, TextEditingController> _controllers;
  late Map<MeasurementCategory, List<MeasurementField>> _grouped;

  bool _upperBodyExpanded = true;
  bool _lowerBodyExpanded = true;

  // Style Preferences
  final List<String> _selectedStyles = [];
  final List<String> _availableStyles = ["Minimalist", "Avant-Garde", "Bridal"];
  final _fabricsController = TextEditingController();

  // Client Notes
  final _notesController = TextEditingController();

  // Design Inspiration
  final List<File> _designImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController.text =
        "Measurement - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

    // Pick gender-appropriate fields
    final gender = widget.customer.gender.toLowerCase();
    _fields = (gender == 'female') ? femaleMeasurements : maleMeasurements;

    // Build a controller for every field
    _controllers = {for (final f in _fields) f.name: TextEditingController()};

    // Group fields by category (upperBody, lowerBody, other)
    _grouped = _fields.groupByCategory();

    // if (widget.customer.stylePreferences != null &&
    //     widget.customer.stylePreferences!.isNotEmpty) {
    //   _selectedStyles.addAll(
    //     widget.customer.stylePreferences!.split(", ").map((s) => s.trim()),
    //   );
    // }
    // _fabricsController.text = widget.customer.favoriteFabrics ?? "";
    // _notesController.text = widget.customer.notes ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    _fabricsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _designImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showPickImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF6200EE),
                ),
                title: Text("Gallery", style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF6200EE)),
                title: Text("Camera", style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveMeasurements() async {
    // Validate: at least 2 measurement fields must be filled
    final filledCount =
        _controllers.values.where((c) => c.text.trim().isNotEmpty).length;

    if (filledCount < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please fill in at least 2 measurements before saving.",
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: const Color(0xFF6200EE),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final measurementId = const Uuid().v4();

    // Build values map from all dynamic controllers
    final values = <String, double>{};
    for (final entry in _controllers.entries) {
      values[entry.key] = double.tryParse(entry.value.text) ?? 0.0;
    }

    final newMeasurement = Measurement(
      id: measurementId,
      customerId: widget.customer.id!,
      name:
          _nameController.text.trim().isEmpty
              ? "Unnamed Measurement"
              : _nameController.text.trim(),
      measurementValues: values,
      createdDate: DateTime.now(),
    );

    final provider = Provider.of<MeasurementProvider>(context, listen: false);
    await provider.addMeasurement(newMeasurement);

    // Save design images
    if (_designImages.isNotEmpty) {
      if (!mounted) return;
      final imageProvider = Provider.of<AppImageProvider>(
        context,
        listen: false,
      );
      for (final imageFile in _designImages) {
        await imageProvider.saveMultipleImage(
          ownerId: measurementId,
          ownerType: ImageOwnerTypes.measurement,
          file: imageFile,
        );
      }
    }

    // Refresh history so it shows up in the profile screen immediately
    await provider.fetchMeasurementsWithCustomer(widget.customer.id!);

    // final updatedCustomer = widget.customer.copyWith(
    //   stylePreferences: _selectedStyles.join(", "),
    //   favoriteFabrics: _fabricsController.text.trim(),
    //   notes: _notesController.text.trim(),
    // );

    // await Provider.of<CustomerProvider>(
    //   context,
    //   listen: false,
    // ).updateCustomer(updatedCustomer);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: CustomAppBar(
        title: "Take Measurements",
        centerTitle: true,
        isLight: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Color(0xFF6200EE)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Customer Info Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFF3E8FF),
                    child: Text(
                      widget.customer.name.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF6200EE),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.customer.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (widget.customer.phone.isNotEmpty)
                          Text(
                            widget.customer.phone,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(Icons.label_outline, "MEASUREMENT NAME"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: TextField(
                controller: _nameController,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "e.g., Wedding Suit, Office Wear...",
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.black26,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(Icons.straighten, "MEASUREMENTS"),
                _buildUnitToggle(),
              ],
            ),
            const SizedBox(height: 12),
            // ── Upper Body ──
            if (_grouped.containsKey(MeasurementCategory.upperBody))
              _buildExpandableSection(
                title: "Upper Body",
                icon: Icons.accessibility_new_rounded,
                isExpanded: _upperBodyExpanded,
                onToggle:
                    () => setState(
                      () => _upperBodyExpanded = !_upperBodyExpanded,
                    ),
                fields: _grouped[MeasurementCategory.upperBody]!,
              ),
            const SizedBox(height: 12),
            // ── Lower Body ──
            if (_grouped.containsKey(MeasurementCategory.lowerBody))
              _buildExpandableSection(
                title: "Lower Body",
                icon: Icons.airline_seat_legroom_normal_rounded,
                isExpanded: _lowerBodyExpanded,
                onToggle:
                    () => setState(
                      () => _lowerBodyExpanded = !_lowerBodyExpanded,
                    ),
                fields: _grouped[MeasurementCategory.lowerBody]!,
              ),
            const SizedBox(height: 24),
            _buildSectionHeader(Icons.auto_awesome, "STYLE PREFERENCES"),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Primary Styles",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._availableStyles.map((style) => _buildStyleTag(style)),
                      _buildAddTag(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Favorite Fabrics",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _fabricsController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Silk, Linen, Sustainable Cotton...",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.black26,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(Icons.image, "DESIGN INSPIRATION"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashed upload zone
                  GestureDetector(
                    onTap: _showPickImageOptions,
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6200EE).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        color: const Color(0xFF6200EE).withValues(alpha: 0.03),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6200EE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cloud_upload_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Upload Reference",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Add fabric swatches, design sketches,\nor mood board photos",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ..._designImages.asMap().entries.map((entry) {
                          int idx = entry.key;
                          File file = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Stack(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: FileImage(file),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _designImages.removeAt(idx);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        // Add more button
                        GestureDetector(
                          onTap: _showPickImageOptions,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade100,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.grey,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(Icons.notes, "CLIENT NOTES"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      "Mention any specific fitting history, allergies to certain materials, or preferred seam finishes...",
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.black26,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: _buildBottomButton(),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6200EE)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5C6280),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildUnitToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildUnitOption("IN", !_isMetric),
          _buildUnitOption("CM", _isMetric),
        ],
      ),
    );
  }

  Widget _buildUnitOption(String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isMetric = label == "CM"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6200EE) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : const Color(0xFF6200EE),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<MeasurementField> fields,
  }) {
    // Build a true 2-column grid using rows of Expanded pairs
    final rows = <Widget>[];
    for (int i = 0; i < fields.length; i += 2) {
      final left = fields[i];
      final hasRight = i + 1 < fields.length;
      final right = hasRight ? fields[i + 1] : null;

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildMeasurementField(
                left.name.toUpperCase(),
                _controllers[left.name]!,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child:
                  right != null
                      ? _buildMeasurementField(
                        right.name.toUpperCase(),
                        _controllers[right.name]!,
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      );

      if (i + 2 < fields.length) rows.add(const SizedBox(height: 12));
    }

    Widget content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(children: rows),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onToggle,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF6200EE)),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              "${fields.length} measurements",
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: isExpanded ? const Color(0xFF6200EE) : Colors.black38,
            ),
          ),
          if (isExpanded) content,
        ],
      ),
    );
  }

  Widget _buildMeasurementField(
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF9095A9),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF424242),
            ),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleTag(String style) {
    bool isSelected = _selectedStyles.contains(style);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedStyles.remove(style);
          } else {
            _selectedStyles.add(style);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6200EE) : const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? const Color(0xFF6200EE) : Colors.black12,
          ),
        ),
        child: Text(
          style,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6200EE),
          ),
        ),
      ),
    );
  }

  Widget _buildAddTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        "+ Add",
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF6200EE),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: GestureDetector(
        onTap: _saveMeasurements,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF6200EE),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6200EE).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            "Save Measurements",
            style: GoogleFonts.poppins(
              fontSize: 15, // Prominent font
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
