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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6200EE).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.straighten,
                color: Color(0xFF6200EE),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Measurements',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Manage client profiles",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF424242),
                size: 18,
              ),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.black.withValues(alpha: 0.02),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
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
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFADADAD),
                      size: 18,
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFF6200EE),
                        size: 16,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children:
                    _categories.map((category) {
                      final bool isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFF6200EE)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(20),
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
                                          ).withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                      : null,
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : const Color(0xFF757575),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 12),

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
                              size: 56,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "No clients found",
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.people_rounded, "Clients", true, () {}),
          _buildNavItem(Icons.assignment_rounded, "Projects", false, () {}),
          _buildNavItem(Icons.calendar_month_rounded, "Orders", false, () {}),
          _buildNavItem(Icons.settings_rounded, "Settings", false, () {}),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isActive
                      ? const Color(0xFF6200EE).withValues(alpha: 0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color:
                  isActive ? const Color(0xFF6200EE) : const Color(0xFF999999),
              size: 22,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color:
                  isActive ? const Color(0xFF6200EE) : const Color(0xFF999999),
            ),
          ),
        ],
      ),
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF5F5F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              () => AppNavigator.toMeasurementDetails(measurement: measurement),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(
                                  0xFF6200EE,
                                ).withValues(alpha: 0.4),
                              ),
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              customer.name,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1C1E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _StatusBadge(isNeedsUpdate: isNeedsUpdate),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        measurement.name.isNotEmpty
                            ? measurement.name
                            : "General Selection",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF6200EE),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: const Color(0xFFADADAD),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade300,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:
            isNeedsUpdate ? const Color(0xFFFFF7E6) : const Color(0xFFE6FFF1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isNeedsUpdate ? "UPDATE" : "OK",
        style: GoogleFonts.poppins(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color:
              isNeedsUpdate ? const Color(0xFFD48806) : const Color(0xFF23B175),
        ),
      ),
    );
  }
}
