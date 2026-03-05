import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/app_image.dart';
import 'package:notdle/models/image_owner_types.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/providers/image_provider.dart';
import 'package:provider/provider.dart';

class MeasurementDetailPage extends StatefulWidget {
  final Measurement measurement;
  static const String tag = "measurement_details";

  const MeasurementDetailPage({super.key, required this.measurement});

  @override
  State<MeasurementDetailPage> createState() => _MeasurementDetailPageState();
}

class _MeasurementDetailPageState extends State<MeasurementDetailPage> {
  bool _isMetric = true;
  List<AppImage> _images = [];
  bool _loadingImages = true;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    final provider = Provider.of<AppImageProvider>(context, listen: false);
    final images = await provider.getImages(
      widget.measurement.id,
      ImageOwnerTypes.measurement,
    );
    if (mounted) {
      setState(() {
        _images = images;
        _loadingImages = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.measurement.customer!;

    // Filter out measurements with value <= 0
    final activeValues =
        widget.measurement.measurementValues.entries
            .where((e) => (e.value) > 0)
            .toList();

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

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Measurements Section ──
                if (activeValues.isEmpty)
                  _buildEmptyMeasurements()
                else ...[
                  _buildSectionHeader(Icons.straighten_rounded, "MEASUREMENTS"),
                  const SizedBox(height: 12),
                  _buildMeasurementGrid(activeValues),
                ],

                const SizedBox(height: 28),

                // ── Design Inspiration Section ──
                _buildSectionHeader(Icons.image_rounded, "DESIGN INSPIRATION"),
                const SizedBox(height: 12),
                _buildInspirationSection(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6200EE)),
        const SizedBox(width: 8),
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
    );
  }

  Widget _buildEmptyMeasurements() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.straighten_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            "No measurement data recorded",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementGrid(List<MapEntry<String, double>> entries) {
    final rows = <Widget>[];
    for (int i = 0; i < entries.length; i += 2) {
      final left = entries[i];
      final right = i + 1 < entries.length ? entries[i + 1] : null;

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildMeasurementCard(left.key, left.value)),
            const SizedBox(width: 12),
            Expanded(
              child:
                  right != null
                      ? _buildMeasurementCard(right.key, right.value)
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      if (i + 2 < entries.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }

  Widget _buildMeasurementCard(String label, double value) {
    final displayValue =
        _isMetric
            ? value.toStringAsFixed(1)
            : (value / 2.54).toStringAsFixed(1);
    final unit = _isMetric ? " cm" : " in";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF9095A9),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                displayValue,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6200EE),
                ),
              ),
              Text(
                unit,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF9095A9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInspirationSection() {
    if (_loadingImages) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(
            color: Color(0xFF6200EE),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_images.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 40,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Text(
              "No design images uploaded",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // 2-column image grid
    final imgRows = <Widget>[];
    for (int i = 0; i < _images.length; i += 2) {
      final left = _images[i];
      final right = i + 1 < _images.length ? _images[i + 1] : null;

      imgRows.add(
        Row(
          children: [
            Expanded(child: _buildInspirationImage(left)),
            const SizedBox(width: 10),
            Expanded(
              child:
                  right != null
                      ? _buildInspirationImage(right)
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      if (i + 2 < _images.length) imgRows.add(const SizedBox(height: 10));
    }

    return Column(children: imgRows);
  }

  Widget _buildInspirationImage(AppImage image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1,
        child:
            image.localPath.isNotEmpty
                ? Image.file(File(image.localPath), fit: BoxFit.cover)
                : Container(
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
      ),
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
