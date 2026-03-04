import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/measurement_provider.dart';
import 'package:provider/provider.dart';

class AllMeasurementScreen extends StatefulWidget {
  const AllMeasurementScreen({super.key});

  static const String tag = "all_measurement";

  @override
  State<AllMeasurementScreen> createState() => _AllMeasurementScreenState();
}

class _AllMeasurementScreenState extends State<AllMeasurementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "All";
  final List<String> _categories = ["All", "Men", "Women", "Children"];

  @override
  void initState() {
    super.initState();
    _fetchMeasurements();
  }

  Future<void> _fetchMeasurements() async {
    await context.read<MeasurementProvider>().getAllMeasurementWithCustomer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allMeasurements = context.watch<MeasurementProvider>().measurements;

    // Filter logic
    final filteredMeasurements =
        allMeasurements.where((m) {
          final query = _searchController.text.toLowerCase();
          final customer = m.customer;
          if (customer == null) return false;

          final matchesSearch =
              customer.name.toLowerCase().contains(query) ||
              customer.phone.contains(query) ||
              m.name.toLowerCase().contains(query);

          if (_selectedCategory == "All") return matchesSearch;

          // Basic gender mapping for categories
          if (_selectedCategory == "Men") {
            return matchesSearch && customer.gender.toLowerCase() == "male";
          } else if (_selectedCategory == "Women") {
            return matchesSearch && customer.gender.toLowerCase() == "female";
          } else if (_selectedCategory == "Children") {
            // Placeholder for children if needed
            return matchesSearch && customer.gender.toLowerCase() == "child";
          }

          return matchesSearch;
        }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Logo & Notifications
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.dashboard_customize_rounded,
                          color: Color(0xFF6200EE),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "StitchFlow",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1C1E),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF424242),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Title section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Measurement Directory",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Manage your client size profiles",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF757575),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Search client name...",
                    hintStyle: GoogleFonts.poppins(
                      color: const Color(0xFFADADAD),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFADADAD),
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFF6200EE),
                        size: 20,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children:
                    _categories.map((category) {
                      final bool isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFF6200EE)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? const Color(0xFF6200EE)
                                        : const Color(0xFFEEEEEE),
                              ),
                              boxShadow:
                                  isSelected
                                      ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF6200EE,
                                          ).withValues(alpha: 0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                      : null,
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : const Color(0xFF757575),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Measurement List
            Expanded(
              child:
                  filteredMeasurements.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off_rounded,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No clients found",
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                        itemCount: filteredMeasurements.length,
                        itemBuilder: (context, index) {
                          return _MeasurementListTile(
                            measurement: filteredMeasurements[index],
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppNavigator.toAddCustomer();
        },
        backgroundColor: const Color(0xFF6200EE),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.people_rounded, "Clients", true),
          _buildNavItem(Icons.architecture_rounded, "Projects", false),
          _buildNavItem(Icons.calendar_today_rounded, "Calendar", false),
          _buildNavItem(Icons.settings_rounded, "Settings", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF6200EE) : const Color(0xFFABABAB),
          size: 26,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? const Color(0xFF6200EE) : const Color(0xFFABABAB),
          ),
        ),
      ],
    );
  }
}

class _MeasurementListTile extends StatelessWidget {
  final Measurement measurement;

  const _MeasurementListTile({required this.measurement});

  @override
  Widget build(BuildContext context) {
    final customer = measurement.customer;
    if (customer == null) return const SizedBox.shrink();

    final date = measurement.createdDate;
    final months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC",
    ];
    final formattedDate =
        "LAST: ${months[date.month - 1]} ${date.day}, ${date.year}";

    // Status logic (simplified)
    final bool isNeedsUpdate = DateTime.now().difference(date).inDays > 180;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF5F5F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              () => AppNavigator.toMeasurementDetails(measurement: measurement),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image:
                        customer.imagePath != null
                            ? DecorationImage(
                              image: FileImage(File(customer.imagePath!)),
                              fit: BoxFit.cover,
                            )
                            : null,
                    color: const Color(0xFFF3E8FF),
                  ),
                  child:
                      customer.imagePath == null
                          ? Center(
                            child: Text(
                              customer.name.substring(0, 1).toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(
                                  0xFF6200EE,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              customer.name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1C1E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _StatusBadge(isNeedsUpdate: isNeedsUpdate),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        measurement.name.isNotEmpty
                            ? measurement.name
                            : "General Selection",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF6200EE),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFFADADAD),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFFADADAD),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isNeedsUpdate;

  const _StatusBadge({required this.isNeedsUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            isNeedsUpdate ? const Color(0xFFFFF7E6) : const Color(0xFFE6FFF1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isNeedsUpdate ? "NEEDS UPDATE" : "COMPLETE",
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color:
              isNeedsUpdate ? const Color(0xFFD48806) : const Color(0xFF23B175),
        ),
      ),
    );
  }
}
