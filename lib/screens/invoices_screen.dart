// lib/screens/invoices_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/financial_provider.dart';
import 'package:notdle/providers/invoice_provider.dart';
import 'package:notdle/screens/invoice_details_screen.dart';
import 'package:notdle/screens/create_invoice_screen.dart';
import 'package:provider/provider.dart';

class _InvoiceWithCustomer {
  final Invoice invoice;
  final String customerName;

  _InvoiceWithCustomer({required this.invoice, required this.customerName});
}

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  static const String tag = "invoices_list";

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  late Future<List<_InvoiceWithCustomer>> _invoicesFuture;
  String _selectedFilter = 'All';
  late Future<double> _totalRevenueFuture;

  @override
  void initState() {
    super.initState();
    _invoicesFuture = _fetchInvoicesWithCustomers();
    // _totalRevenueFuture is now handled by the Consumer
  }

  Future<List<_InvoiceWithCustomer>> _fetchInvoicesWithCustomers() async {
    try {
      if (!mounted) return [];
      final invoiceProvider = Provider.of<InvoiceProvider>(
        context,
        listen: false,
      );
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );

      await invoiceProvider.fetchInvoices();
      final invoices = invoiceProvider.invoices;

      final List<_InvoiceWithCustomer> detailedInvoices = [];

      for (final invoice in invoices) {
        final customer = await customerProvider.getCustomerById(
          invoice.customerId,
        );
        detailedInvoices.add(
          _InvoiceWithCustomer(
            invoice: invoice,
            customerName: customer?.name ?? "Unknown Customer",
          ),
        );
      }
      return detailedInvoices;
    } catch (e, stacktrace) {
      print("Error fetching invoices: $e");
      print(stacktrace);
      rethrow;
    }
  }

  void _refreshInvoices() {
    if (mounted) {
      setState(() {
        _invoicesFuture = _fetchInvoicesWithCustomers();
      });
    }
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
                color: const Color(0xFF6200EE).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
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
                  'Invoices',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Manage payment records',
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
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async => _refreshInvoices(),
              child: FutureBuilder<List<_InvoiceWithCustomer>>(
                future: _invoicesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "An error occurred: ${snapshot.error}",
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  }

                  final allInvoices = snapshot.data ?? [];
                  final filteredInvoices =
                      _selectedFilter == 'All'
                          ? allInvoices
                          : allInvoices
                              .where((i) => i.invoice.status == _selectedFilter)
                              .toList();

                  return CustomScrollView(
                    slivers: [
                      // --- Custom Header ---
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Invoices",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1C1E),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _RevenueSummaryCards(invoices: allInvoices),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "RECENT INVOICES",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Row(
                                      children: [
                                        Text(
                                          "See All",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF6200EE),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_right_alt,
                                          size: 20,
                                          color: Color(0xFF6200EE),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _FilterSection(
                                selectedFilter: _selectedFilter,
                                onFilterChanged: (filter) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      // --- Invoice List ---
                      if (filteredInvoices.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Text(
                              "No invoices found.",
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final item = filteredInvoices[index];
                              return _InvoiceListItem(
                                invoice: item.invoice,
                                customerName: item.customerName,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => InvoiceDetailsScreen(
                                            invoice: item.invoice,
                                          ),
                                    ),
                                  );
                                  _refreshInvoices();
                                },
                              );
                            }, childCount: filteredInvoices.length),
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ), // Padding for FAB
                    ],
                  );
                },
              ),
            ),
            // --- Sticky Action Button ---
            Positioned(
              bottom: 100,
              right: 20,
              child: FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateInvoiceScreen(),
                    ),
                  );
                  _refreshInvoices();
                },
                backgroundColor: const Color(0xFF6200EE),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
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
          _buildNavItem(Icons.people_rounded, "Clients", false, () {}),
          _buildNavItem(Icons.assignment_rounded, "Orders", false, () {}),
          _buildNavItem(Icons.receipt_long_rounded, "Invoices", true, () {}),
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

class _RevenueSummaryCards extends StatelessWidget {
  final List<_InvoiceWithCustomer> invoices;

  const _RevenueSummaryCards({required this.invoices});

  @override
  Widget build(BuildContext context) {
    double pendingAmount = 0;
    double overdueAmount = 0;

    for (var item in invoices) {
      if (item.invoice.status == 'Pending') {
        pendingAmount += item.invoice.total ?? 0;
      }
      // Simple overdue logic for placeholder
      if (item.invoice.status != 'Paid' &&
          item.invoice.date != null &&
          item.invoice.date!.isBefore(DateTime.now())) {
        overdueAmount += item.invoice.total ?? 0;
      }
    }

    return Column(
      children: [
        Consumer<FinancialProvider>(
          builder: (context, financialProvider, child) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6200EE), Color(0xFF5100C4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6200EE).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: FutureBuilder<double>(
                future: financialProvider.getTotalRevenue(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }
                  final totalRevenue = snapshot.data ?? 0.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TOTAL REVENUE",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        NumberFormat.currency(
                          symbol: '\$',
                        ).format(totalRevenue),
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Colors.lightGreenAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "+12.5% vs last month",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.lightGreenAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SummarySubCard(
                label: "PENDING",
                amount: pendingAmount,
                color: const Color(0xFF6200EE),
                showProgress: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SummarySubCard(
                label: "OVERDUE",
                amount: overdueAmount,
                color: Colors.orange,
                subtitle: "3 invoices delayed",
                showWarning: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummarySubCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String? subtitle;
  final bool showProgress;
  final bool showWarning;

  const _SummarySubCard({
    required this.label,
    required this.amount,
    required this.color,
    this.subtitle,
    this.showProgress = false,
    this.showWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              if (showWarning)
                const Icon(Icons.priority_high, color: Colors.orange, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(symbol: '\$').format(amount),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 12),
          if (showProgress)
            Stack(
              children: [
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  height: 4,
                  width: 60, // Placeholder progress
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            )
          else if (subtitle != null)
            Text(
              subtitle!,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  _FilterSection({required this.selectedFilter, required this.onFilterChanged});

  final List<String> filters = ['All', 'Paid', 'Pending', 'Overdue'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            filters.map((filter) {
              final isSelected = selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => onFilterChanged(filter),
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF6200EE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          isSelected
                              ? Colors.transparent
                              : Colors.grey.shade100,
                    ),
                  ),
                  elevation: isSelected ? 4 : 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _InvoiceListItem extends StatelessWidget {
  final Invoice invoice;
  final String customerName;
  final VoidCallback onTap;

  const _InvoiceListItem({
    required this.invoice,
    required this.customerName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(invoice.status);
    final statusIcon = _getStatusIcon(invoice.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "#ST-${invoice.id.length > 6 ? invoice.id.substring(0, 6).toUpperCase() : invoice.id.toUpperCase()} • ${DateFormat('MMM d, y').format(invoice.date ?? DateTime.now())}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat.currency(
                    symbol: '\$',
                  ).format(invoice.total ?? 0),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1C1E),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    invoice.status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
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
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Overdue':
        return Colors.red;
      case 'Pending':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Paid':
        return Icons.check_circle_outline;
      case 'Overdue':
        return Icons.warning_amber_rounded;
      case 'Pending':
        return Icons.access_time;
      default:
        return Icons.receipt_long_outlined;
    }
  }
}

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
