import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/measurement.dart';
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
  final _bustController = TextEditingController();
  final _waistController = TextEditingController();
  final _shouldersController = TextEditingController();
  final _sleeveController = TextEditingController();

  bool _upperBodyExpanded = true;
  bool _lowerBodyExpanded = false;

  @override
  void dispose() {
    _bustController.dispose();
    _waistController.dispose();
    _shouldersController.dispose();
    _sleeveController.dispose();
    super.dispose();
  }

  Future<void> _saveMeasurements() async {
    final measurementId = const Uuid().v4();
    final values = {
      "Bust": double.tryParse(_bustController.text) ?? 0.0,
      "Waist": double.tryParse(_waistController.text) ?? 0.0,
      "Shoulders": double.tryParse(_shouldersController.text) ?? 0.0,
      "Sleeve": double.tryParse(_sleeveController.text) ?? 0.0,
    };

    final newMeasurement = Measurement(
      id: measurementId,
      customerId: widget.customer.id!,
      name: "Initial Profile Measurement",
      measurementValues: values,
      createdDate: DateTime.now(),
    );

    await Provider.of<MeasurementProvider>(
      context,
      listen: false,
    ).addMeasurement(newMeasurement);

    if (mounted) {
      Navigator.pop(
        context,
      ); // Also potentially pop to specific route, but pop is fine.
    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(Icons.straighten, "MEASUREMENTS"),
                _buildUnitToggle(),
              ],
            ),
            const SizedBox(height: 12),
            _buildExpandableSection(
              title: "Upper Body",
              isExpanded: _upperBodyExpanded,
              onToggle:
                  () =>
                      setState(() => _upperBodyExpanded = !_upperBodyExpanded),
              content: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMeasurementField("BUST", _bustController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMeasurementField(
                          "WAIST",
                          _waistController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMeasurementField(
                          "SHOULDERS",
                          _shouldersController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMeasurementField(
                          "SLEEVE",
                          _sleeveController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildExpandableSection(
              title: "Lower Body",
              isExpanded: _lowerBodyExpanded,
              onToggle:
                  () =>
                      setState(() => _lowerBodyExpanded = !_lowerBodyExpanded),
              content: const SizedBox.shrink(),
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
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
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
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: isExpanded ? const Color(0xFF6200EE) : Colors.black38,
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: content,
            ),
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
                color: const Color(0xFF6200EE).withOpacity(0.3),
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
