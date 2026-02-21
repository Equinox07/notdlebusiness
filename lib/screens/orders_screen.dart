// lib/screens/orders_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:notdle/screens/create_order_screen.dart';
import 'package:notdle/screens/order_details_screen.dart';
import 'package:provider/provider.dart';

class _OrderWithCustomer {
  final Order order;
  final String customerName;

  _OrderWithCustomer({required this.order, required this.customerName});
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  static const String tag = "orders";

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<_OrderWithCustomer>> _ordersFuture;
  String _searchQuery = "";
  String _selectedFilter = "All";
  final List<String> _filters = ["All", "In Progress", "Ready", "Delivered"];

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrdersWithCustomers();
  }

  Future<List<_OrderWithCustomer>> _fetchOrdersWithCustomers() async {
    if (!mounted) return [];
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );

    await orderProvider.fetchOrders();
    final orders = orderProvider.orders;

    final List<_OrderWithCustomer> detailedOrders = [];

    for (final order in orders) {
      final customer = await customerProvider.getCustomerById(order.customerId);
      detailedOrders.add(
        _OrderWithCustomer(
          order: order,
          customerName: customer?.name ?? "Unknown Customer",
        ),
      );
    }
    return detailedOrders;
  }

  void _refreshOrders() {
    if (mounted) {
      setState(() {
        _ordersFuture = _fetchOrdersWithCustomers();
      });
    }
  }

  List<_OrderWithCustomer> _applyFilters(List<_OrderWithCustomer> data) {
    return data.where((item) {
      final matchesSearch =
          item.customerName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item.order.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.order.orderNumber?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);

      final matchesFilter =
          _selectedFilter == "All" || item.order.status == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: const _AbstractAppBarBackground(),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
        ),
        title: Text(
          "Garment Orders",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.black87,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async => _refreshOrders(),
              child: CustomScrollView(
                slivers: [
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged:
                              (value) => setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: "Search client, fabric or style...",
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF6200EE),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Filter Chips
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Row(
                        children:
                            _filters.map((filter) {
                              final isSelected = _selectedFilter == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ChoiceChip(
                                  label: Text(filter),
                                  selected: isSelected,
                                  onSelected:
                                      (_) => setState(
                                        () => _selectedFilter = filter,
                                      ),
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                  ),
                                  backgroundColor: Colors.white,
                                  selectedColor: const Color(0xFF6200EE),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color:
                                          isSelected
                                              ? Colors.transparent
                                              : Colors.grey.shade200,
                                    ),
                                  ),
                                  elevation: isSelected ? 3 : 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),

                  // Section Label
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "RECENT ORDERS",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Orders List
                  FutureBuilder<List<_OrderWithCustomer>>(
                    future: _ordersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Text("Error: ${snapshot.error}"),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Text(
                              "No Orders Found",
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          ),
                        );
                      } else {
                        final filteredData = _applyFilters(snapshot.data!);
                        if (filteredData.isEmpty) {
                          return SliverFillRemaining(
                            child: Center(
                              child: Text(
                                "No matching orders",
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final item = filteredData[index];
                              return _OrderCard(
                                order: item.order,
                                customerName: item.customerName,
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => OrderDetailsScreen(
                                            order: item.order,
                                          ),
                                    ),
                                  );
                                  _refreshOrders();
                                },
                              );
                            }, childCount: filteredData.length),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            // Sticky FAB-style button
            Positioned(
              bottom: 24,
              right: 20,
              child: FloatingActionButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateOrderScreen(),
                    ),
                  );
                  _refreshOrders();
                },
                backgroundColor: const Color(0xFF6200EE),
                elevation: 6,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Order Card ─────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final Order order;
  final String customerName;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.customerName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final isPaid = order.paymentStatus.toLowerCase() == 'paid';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status color indicator + icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.content_cut_rounded,
                color: statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 11,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(order.dueDate),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "#${order.orderNumber?.substring(0, 4) ?? '---'}",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Right side: status + payment badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isPaid
                            ? const Color(0xFFFFF9E7)
                            : const Color(0xFFF1F4F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPaid ? Icons.payments_outlined : Icons.info_outline,
                        size: 10,
                        color:
                            isPaid
                                ? const Color(0xFFF39C12)
                                : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        order.paymentStatus.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color:
                              isPaid
                                  ? const Color(0xFFF39C12)
                                  : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
      case 'sewing in progress':
        return Colors.orange.shade700;
      case 'fitting stage':
        return Colors.deepPurple.shade400;
      case 'ready':
      case 'ready for pickup':
        return const Color(0xFF2ECC71);
      case 'delivered':
        return Colors.blue.shade600;
      default:
        return const Color(0xFF6200EE);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "No date";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, y').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

// ─── AppBar Background (matches InvoicesScreen) ──────────────────────────────

class _AbstractAppBarBackground extends StatelessWidget {
  const _AbstractAppBarBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6200EE).withOpacity(0.05),
            Colors.grey.shade50,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -20,
            child: _AbstractBlob(
              color: const Color(0xFF6200EE).withOpacity(0.03),
              size: 150,
            ),
          ),
          Positioned(
            left: -30,
            bottom: -40,
            child: _AbstractBlob(
              color: Colors.amber.withOpacity(0.02),
              size: 120,
            ),
          ),
          CustomPaint(size: Size.infinite, painter: _AppBarPatternPainter()),
        ],
      ),
    );
  }
}

class _AbstractBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _AbstractBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _AppBarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF6200EE).withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 1.0,
      size.width,
      size.height * 0.7,
    );
    canvas.drawPath(path, paint);

    final path2 = Path();
    path2.moveTo(size.width * 0.1, 0);
    path2.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.5,
      size.width * 0.1,
      size.height,
    );
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
