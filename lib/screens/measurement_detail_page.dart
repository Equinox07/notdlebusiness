import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/measurement.dart';

class MeasurementDetailPage extends StatefulWidget {
  final Measurement measurement;
  static const String tag = "measurement_details";

  const MeasurementDetailPage({super.key, required this.measurement});

  @override
  State<MeasurementDetailPage> createState() => _MeasurementDetailPageState();
}

class _MeasurementDetailPageState extends State<MeasurementDetailPage> {
  bool _isMetric = true;

  @override
  Widget build(BuildContext context) {
    final customer = widget.measurement.customer!;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF6200EE),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    customer.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1C1E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "VIP",
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6200EE),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              "RAPID ENTRY MODE",
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: const Color(0xFFADADAD),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          _buildGuideButton(),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6200EE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                "SAVE",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Unit toggle and Search
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildUnitOption("CM", _isMetric),
                      _buildUnitOption("IN", !_isMetric),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "SEARCH:",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFADADAD),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.search,
                      color: Color(0xFFADADAD),
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // Measurement Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildSection("UPPER BODY", Icons.person_rounded, [
                  _MeasurementItem(
                    label: "Neck",
                    value: "34.5",
                    hasHistory: true,
                  ),
                  _MeasurementItem(
                    label: "Shoulder",
                    value: "42.0",
                    hasHistory: true,
                  ),
                  _MeasurementItem(
                    label: "Bust",
                    value:
                        widget.measurement.measurementValues["Bust"]
                            ?.toStringAsFixed(1) ??
                        "92.4",
                    hasHistory: true,
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSection("LOWER BODY", Icons.straighten_rounded, [
                  _MeasurementItem(
                    label: "Waist",
                    value:
                        widget.measurement.measurementValues["Waist"]
                            ?.toStringAsFixed(1) ??
                        "70.2",
                    hasHistory: true,
                  ),
                  _MeasurementItem(
                    label: "Hips",
                    value:
                        widget.measurement.measurementValues["Hip"]
                            ?.toStringAsFixed(1) ??
                        "96.8",
                    hasHistory: true,
                  ),
                  _MeasurementItem(
                    label: "Inseam",
                    value: "78.0",
                    hasHistory: true,
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSection("ARMS & LEGS", Icons.architecture_rounded, [
                  _MeasurementItem(
                    label: "Sleeve",
                    value:
                        widget.measurement.measurementValues["Sleeve"]
                            ?.toStringAsFixed(1) ??
                        "58.5",
                    hasHistory: true,
                  ),
                  _MeasurementItem(
                    label: "Thigh",
                    value:
                        widget.measurement.measurementValues["Thigh"]
                            ?.toStringAsFixed(1) ??
                        "54.2",
                    hasHistory: true,
                  ),
                  _MeasurementItem(
                    label: "Ankle",
                    value: "23.0",
                    hasHistory: true,
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildUnitOption(String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isMetric = label == "CM"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFF6200EE) : const Color(0xFFADADAD),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "GUIDE",
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD48806),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E6),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFFFE58F)),
          ),
          child: const Icon(
            Icons.accessibility_new_rounded,
            size: 20,
            color: Color(0xFFD48806),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF6200EE)),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6200EE),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Divider(color: Color(0xFFEEEEEE))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomActionItem(Icons.edit_note_rounded, "RECORD", true),
          _buildBottomActionItem(
            Icons.compare_arrows_rounded,
            "COMPARE",
            false,
          ),
          _buildBottomActionItem(Icons.file_upload_outlined, "EXPORT", false),
          _buildBottomActionItem(Icons.print_outlined, "PRINT TAG", false),
        ],
      ),
    );
  }

  Widget _buildBottomActionItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF6200EE) : const Color(0xFFADADAD),
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFF6200EE) : const Color(0xFFADADAD),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _MeasurementItem extends StatelessWidget {
  final String label;
  final String value;
  final bool hasHistory;

  const _MeasurementItem({
    required this.label,
    required this.value,
    required this.hasHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1C1E),
                ),
              ),
            ),
            if (hasHistory)
              const Icon(
                Icons.history_rounded,
                color: Color(0xFFD1D5DB),
                size: 20,
              ),
            const SizedBox(width: 16),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6200EE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
