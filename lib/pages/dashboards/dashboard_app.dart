// DashboardAppScreen
// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/dashboard_provider.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:notdle/widgets/deadline_card.dart';
import 'package:provider/provider.dart';

class DashboardAppScreen extends StatefulWidget {
  const DashboardAppScreen({super.key});

  static const String tag = "dashboard_screen_app";

  @override
  State<DashboardAppScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardAppScreen> {
  late Future<Company?> _companyFuture;
  // final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _companyFuture = SessionManager.getCompany();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashBoardProvider>(context, listen: false).fetchCounts();
    });
  }

  // Future<Map<String, int>> _fetchCounts() async {
  //   final orderCount = await Future.value(dashboardProvider.orderCount);
  //   final customerCount = await Future.value(dashboardProvider.customerCount);
  //   return {'orders': orderCount, 'customers': customerCount};
  // }

  @override
  Widget build(BuildContext context) {
    //Listen for latest updates
    final dashboardProvider = Provider.of<DashBoardProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black87),
            onPressed: () => AppNavigator.toProfile(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade600, Colors.indigo.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: FutureBuilder<Company?>(
                future: _companyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: Text(
                        "No company data found. Please log in.",
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  }

                  final company = snapshot.data!;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Good morning, ${company.fullName} 👋',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Here's what's happening with your business.",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const CircleAvatar(
                                backgroundColor: Colors.white30,
                                radius: 30,
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Summary Stats Section
            _buildSectionTitle(context, 'Summary'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // FutureBuilder<int>(
                //   future: DatabaseHelper.instance.getCustomerCount(),
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return const CircularProgressIndicator();
                //     }
                //     return  _StatCard(
                //         title: 'Customers',
                //         value: "${snapshot.data ?? 0}",
                //         icon: Icons.group,
                //         color: Colors.green,
                //         onTap: () => AppNavigator.toCustomers(),
                //     );
                //   },
                // ),
                _StatCard(
                  title: 'Customers',
                  value: dashboardProvider.customerCount.toString(),
                  icon: Icons.group,
                  color: Colors.green,
                  onTap: () => AppNavigator.toCustomers(),
                ),
                _StatCard(
                  title: 'Orders',
                  value: dashboardProvider.orderCount.toString(),
                  icon: Icons.shopping_cart_rounded,
                  color: Colors.indigo,
                  onTap: () => AppNavigator.toOrders(),
                ),
                // FutureBuilder<int>(
                //   future: DatabaseHelper.instance.getActiveOrderCount(),
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return const CircularProgressIndicator();
                //     }
                //     return _StatCard(
                //         title: 'Orders',
                //         value:  "${snapshot.data ?? 0}",
                //         icon: Icons.shopping_cart_rounded,
                //         color: Colors.indigo,
                //         onTap: () => AppNavigator.toOrders(),
                //     );
                //   },
                // ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatCard(
                  title: 'Measurements',
                  value: "0",
                  icon: Icons.straighten,
                  color: Colors.deepOrange,
                  onTap: () => AppNavigator.toMeasurement(),
                ),
                _StatCard(
                  title: 'Invoices',
                  value: "0",
                  icon: Icons.attach_money,
                  color: Colors.deepOrange,
                  onTap: () => AppNavigator.toInvoice(),
                ),

                // FutureBuilder<int>(
                //   future: DatabaseHelper.instance.getActiveOrderCount(),
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return const CircularProgressIndicator();
                //     }
                //     return _StatCard(
                //       title: 'Orders',
                //       value:  "${snapshot.data ?? 0}",
                //       icon: Icons.shopping_cart_rounded,
                //       color: Colors.indigo,
                //       onTap: () => AppNavigator.toOrders(),
                //     );
                //   },
                // ),
              ],
            ),

            // _HomeMenuCard(
            //   title: 'Measurements',
            //   subtitle: 'Take & update',
            //   icon: Icons.straighten,
            //   color: Colors.orange.shade600,
            //   onTap: () => AppNavigator.toMeasurement(),
            // ),
            const SizedBox(height: 24),
            // Quick Actions Section
            _buildSectionTitle(context, 'Quick Actions'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionCard(
                  title: 'Add New Order',
                  icon: Icons.add_circle_outline,
                  onTap: () => AppNavigator.toCreateNewOrder(),
                ),
                const SizedBox(width: 10),
                _ActionCard(
                  title: 'Add New Client',
                  icon: Icons.person_add_alt,
                  onTap: () => AppNavigator.toAddCustomer(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Deadlines Section
            _buildSectionTitle(context, 'Recent Deadlines'),
            const SizedBox(height: 12),
            DeadlineCard(
              orderFuture: Future.value(dashboardProvider.soonestDueOrder),
              onTap: () => debugPrint("Orders"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

// Private helper widgets for the dashboard
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.indigo.shade600),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  const _DeadlineCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.watch_later_outlined,
            color: Colors.red.shade600,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Website Redesign",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Due in 2 days",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "June 10",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
