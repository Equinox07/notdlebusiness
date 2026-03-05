// lib/screens/customers_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/screens/add_customer_screen.dart';
import 'package:notdle/screens/customer_detail_screen.dart';
import 'package:provider/provider.dart';

const _kPurple = Color(0xFF6200EE);
const _kBg = Color(0xFFF3F2F7);

// Simple tag enum — VIP/Frequent/New assigned by order count heuristic
enum _ClientTag { all, vip, frequent, newClient }

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});
  static const String tag = "customers";

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _customers = [];
  List<Customer> _filtered = [];
  bool _isLoading = true;
  _ClientTag _activeTag = _ClientTag.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final cp = Provider.of<CustomerProvider>(context, listen: false);
    await cp.fetchCustomers();
    if (!mounted) return;
    setState(() {
      _customers = cp.customers;
      _filtered = _customers;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered =
          _customers.where((c) {
            final matchesSearch =
                c.name.toLowerCase().contains(query) || c.phone.contains(query);
            final matchesTag = _tagMatches(c);
            return matchesSearch && matchesTag;
          }).toList();
    });
  }

  // Heuristic: classify by lastVisit recency
  _ClientTag _inferTag(Customer c) {
    final daysSince = DateTime.now().difference(c.lastVisit).inDays;
    if (daysSince <= 7) return _ClientTag.newClient;
    if (daysSince <= 60) return _ClientTag.frequent;
    return _ClientTag.vip; // oldest / high-value fallback
  }

  bool _tagMatches(Customer c) {
    if (_activeTag == _ClientTag.all) return true;
    return _inferTag(c) == _activeTag;
  }

  void _setTag(_ClientTag tag) {
    setState(() => _activeTag = tag);
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                color: _kPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.people_rounded,
                color: _kPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Clients',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Manage customer profiles',
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
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Search by name or phone...",
                    hintStyle: GoogleFonts.poppins(
                      color: const Color(0xFFADADAD),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFADADAD),
                      size: 18,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _TagPill(
                    label: "All",
                    active: _activeTag == _ClientTag.all,
                    onTap: () => _setTag(_ClientTag.all),
                  ),
                  _TagPill(
                    label: "VIP",
                    active: _activeTag == _ClientTag.vip,
                    onTap: () => _setTag(_ClientTag.vip),
                  ),
                  _TagPill(
                    label: "Frequent",
                    active: _activeTag == _ClientTag.frequent,
                    onTap: () => _setTag(_ClientTag.frequent),
                  ),
                  _TagPill(
                    label: "New",
                    active: _activeTag == _ClientTag.newClient,
                    onTap: () => _setTag(_ClientTag.newClient),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // List
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final customer = _filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ClientCard(
                              customer: customer,
                              tag: _inferTag(customer),
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => CustomerDetailScreen(
                                            customer: customer,
                                          ),
                                    ),
                                  ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCustomer = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
          );
          if (newCustomer != null && newCustomer is Customer && mounted) {
            setState(() {
              _customers.add(newCustomer);
              _filtered = _customers;
            });
          }
        },
        backgroundColor: _kPurple,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            "No clients found",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Tap + to add your first client",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
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
                      ? _kPurple.withValues(alpha: 0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isActive ? _kPurple : const Color(0xFF999999),
              size: 22,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? _kPurple : const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Pill ───────────────────────────────────────────────────────────────

class _TagPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TagPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _kPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              active
                  ? [
                    BoxShadow(
                      color: _kPurple.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

// ── Client Card ───────────────────────────────────────────────────────────────

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  const CustomerCard({super.key, required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _ClientCard(customer: customer, onTap: onTap);
  }
}

class _ClientCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final _ClientTag? tag;

  const _ClientCard({required this.customer, required this.onTap, this.tag});

  @override
  Widget build(BuildContext context) {
    final lastVisitStr = _formatLastVisit(customer.lastVisit);
    final badgeData = _badgeFor(tag);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Photo ──────────────────────────────────────────────────
              _buildAvatar(),
              const SizedBox(width: 12),

              // ── Info ───────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name row + badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0D0D0D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badgeData != null) ...[
                          const SizedBox(width: 6),
                          _Badge(label: badgeData.$1, color: badgeData.$2),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      customer.phone,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Last visit + balance row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Last: $lastVisitStr",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        FutureBuilder<int>(
                          future: Provider.of<CustomerProvider>(
                            context,
                            listen: false,
                          ).getOrderCountForCustomer(customer.id!),
                          builder: (context, snapshot) {
                            final count = snapshot.data ?? 0;
                            final hasBalance = count > 0;
                            return Text(
                              hasBalance
                                  ? "Bal: \$${(count * 85).toStringAsFixed(2)}"
                                  : "No Balance",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight:
                                    hasBalance
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                color:
                                    hasBalance
                                        ? const Color(0xFFD4900A)
                                        : Colors.grey.shade400,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    const double size = 48;
    if (customer.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(customer.imagePath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderAvatar(size),
        ),
      );
    }
    if (customer.profileImageUrl != null &&
        customer.profileImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          customer.profileImageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderAvatar(size),
        ),
      );
    }
    return _placeholderAvatar(size);
  }

  Widget _placeholderAvatar(double size) {
    final initials =
        customer.name
            .trim()
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _kPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _kPurple,
          ),
        ),
      ),
    );
  }

  String _formatLastVisit(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return "Today";
    if (diff == 1) return "Yesterday";
    return DateFormat('MMM dd, yyyy').format(date);
  }

  (String, Color)? _badgeFor(_ClientTag? t) {
    switch (t) {
      case _ClientTag.vip:
        return ("VIP", const Color(0xFFD4900A));
      case _ClientTag.frequent:
        return ("FREQUENT", _kPurple);
      default:
        return null;
    }
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
