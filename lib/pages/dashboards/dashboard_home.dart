import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/db/database_helper.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/dashboard_provider.dart';
import 'package:notdle/providers/notification_provider.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:notdle/widgets/action_card.dart';
import 'package:notdle/widgets/deadline_card.dart';
import 'package:provider/provider.dart';

// Assume this exists

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late Future<Company?> _companyFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _companyFuture = SessionManager.getCompany();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashBoardProvider>(context, listen: false).fetchCounts();
    } );
  }


  @override
  Widget build(BuildContext context) {
    //Listen for latest updates
    final dashboardProvider = Provider.of<DashBoardProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, Sarah!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Welcome back to your workspace',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          // ➡️ Wrap the notification icon and its count in a Stack
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => AppNavigator.toNotifications(),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3', // Dynamic count
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),

          // The account icon remains separate
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black87),
            onPressed: () =>  AppNavigator.toProfile() ,
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(text: "Quick Actions"),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ActionCard(
                    title: 'New Client',
                    icon: Icons.person_add_alt,
                    onTap: () => AppNavigator.toAddCustomer(),
                  ),

                  const SizedBox(width: 10),
                  ActionCard(
                    title: 'New Order',
                    icon: Icons.add_circle_outline,
                    onTap: () => AppNavigator.toCreateNewOrder(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ActionCard(title: "New Client", icon: Icons.person, onTap: () => {}),
              // Next Appointment Section
              // _SectionTitle(text: "Your Next Appointment"),
              // const SizedBox(height: 12),
              // _AppointmentFocusCard(
              //   title: "Fitting - Wedding Dress",
              //   customerName: "Emma Johnson",
              //   time: "2:30 PM",
              // ),
              // const SizedBox(height: 32),
              _SectionTitle(text: "Deadlines"),
              const SizedBox(height: 12),
              DeadlineCard(
                orderFuture: DatabaseHelper.instance.getSoonestDueOrder(),
                onTap: () => debugPrint("Orders"),
              ),

              const SizedBox(height: 32),

              // Quick Stats Section
              _SectionTitle(text: "Quick Stats"),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickStatCard(
                      value: dashboardProvider.orderCount.toString(),
                      label: 'Active Orders',
                      color: Colors.blue,
                      isTablet: isTablet,
                    ),
                  ),
                  // Text(
                  //   'Total Orders: ${snapshot.data ?? 0}',
                  //   style: Theme.of(context).textTheme.headlineMedium,
                  // );
                  const SizedBox(width: 30),

                  // Expanded(
                  //   child: _QuickStatCard(
                  //     value: '24',
                  //     label: 'Active Orders',
                  //     color: Colors.blue,
                  //     isTablet: isTablet,
                  //   ),
                  // ),
                  // Quick Stats Section
                  Expanded(
                    child: _QuickStatCard(
                      value: dashboardProvider.customerCount.toString(),
                      label: 'Total Customers',
                      color: Colors.green,
                      isTablet: isTablet,
                    ),
                  ),
                  // Expanded(
                  //   child: _QuickStatCard(
                  //     value: '156',
                  //     label: 'Total Customers',
                  //     color: Colors.green,
                  //     isTablet: isTablet,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 32),
              // Menu Options Section
              _SectionTitle(text: "Services"),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isTablet ? 3 : 2,
                crossAxisSpacing: isTablet ? 20 : 16,
                mainAxisSpacing: isTablet ? 20 : 16,
                childAspectRatio: isTablet ? 1.2 : 1.1,
                children: [
                  _HomeMenuCard(
                    title: 'Customers',
                    subtitle: 'Manage clients',
                    icon: Icons.people_outline,
                    color: Colors.blue.shade600,
                    onTap: () => AppNavigator.toCustomers(),
                  ),
                  _HomeMenuCard(
                    title: 'Measurements',
                    subtitle: 'Take & update',
                    icon: Icons.straighten,
                    color: Colors.orange.shade600,
                    onTap: () => AppNavigator.toMeasurement(),
                  ),
                  _HomeMenuCard(
                    title: 'Orders',
                    subtitle: 'Track progress',
                    icon: Icons.shopping_bag_outlined,
                    color: Colors.green.shade600,
                    onTap: () => AppNavigator.toOrders(),
                  ),
                  _HomeMenuCard(
                    title: 'Designs',
                    subtitle: 'Style catalog',
                    icon: Icons.palette_outlined,
                    color: Colors.purple.shade600,
                    onTap:
                        () => debugPrint("Designs"), //AppNavigator.toDesigns(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// The new, visually distinct card for appointments
class _AppointmentFocusCard extends StatelessWidget {
  final String title;
  final String customerName;
  final String time;

  const _AppointmentFocusCard({
    required this.title,
    required this.customerName,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50), // A dark, professional blue
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF4A607C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.calendar_today, color: Colors.white, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customerName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isTablet;

  const _QuickStatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 32 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade600,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: isTablet ? 14 : 12,
            ),
            textAlign: TextAlign.center,
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

// class DashboardHome extends StatelessWidget {
//   const DashboardHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Good morning, Sarah!',
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               'Welcome back to your workspace',
//               style: GoogleFonts.poppins(fontSize: 12),
//             ),
//           ],
//         ),
//         actions: const [Icon(Icons.more_vert)],
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final isTablet = constraints.maxWidth > 600;
//             final padding = isTablet ? 32.0 : 20.0;

//             return SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.all(padding),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Next Appointment
//                     const SectionTitle("Your Next Appointment"),
//                     const SizedBox(height: 12),
//                     const AppointmentCard(
//                       "Fitting - Wedding Dress",
//                       "Emma Johnson",
//                       "Today",
//                       "2:30 PM",
//                     ),
//                     SizedBox(height: isTablet ? 40 : 32),

//                     // Quick stats
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             padding: EdgeInsets.all(isTablet ? 20 : 16),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withValues(alpha: 0.05),
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   '24',
//                                   style: TextStyle(
//                                     fontSize: isTablet ? 32 : 28,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blue.shade600,
//                                   ),
//                                 ),
//                                 Text(
//                                   'Active Orders',
//                                   style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: isTablet ? 14 : 12,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: isTablet ? 20 : 16),
//                         Expanded(
//                           child: Container(
//                             padding: EdgeInsets.all(isTablet ? 20 : 16),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withValues(alpha: 0.05),
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   '156',
//                                   style: TextStyle(
//                                     fontSize: isTablet ? 32 : 28,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green.shade600,
//                                   ),
//                                 ),
//                                 Text(
//                                   'Total Customers',
//                                   style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: isTablet ? 14 : 12,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: isTablet ? 40 : 32),

//                     // Menu options
//                     Text(
//                       'Services',
//                       style: TextStyle(
//                         fontSize: isTablet ? 24 : 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey.shade800,
//                       ),
//                     ),
//                     SizedBox(height: isTablet ? 20 : 16),

//                     // Grid with responsive columns
//                     GridView.count(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       crossAxisCount: isTablet ? 3 : 2,
//                       childAspectRatio: isTablet ? 1.2 : 1.1,
//                       crossAxisSpacing: isTablet ? 20 : 16,
//                       mainAxisSpacing: isTablet ? 20 : 16,
//                       children: [
//                         HomeMenuCard(
//                           title: 'Customers',
//                           subtitle: 'Manage clients',
//                           icon: Icons.people_outline,
//                           color: Colors.blue.shade600,
//                           onTap: () => AppNavigator.toCustomers(),
//                         ),
//                         HomeMenuCard(
//                           title: 'Measurements',
//                           subtitle: 'Take & update',
//                           icon: Icons.straighten,
//                           color: Colors.orange.shade600,
//                           onTap: () => AppNavigator.toMeasurement(),
//                         ),
//                         HomeMenuCard(
//                           title: 'Orders',
//                           subtitle: 'Track progress',
//                           icon: Icons.shopping_bag_outlined,
//                           color: Colors.green.shade600,
//                           onTap: () => AppNavigator.toOrders(),
//                         ),
//                         HomeMenuCard(
//                           title: 'Designs',
//                           subtitle: 'Style catalog',
//                           icon: Icons.palette_outlined,
//                           color: Colors.purple.shade600,
//                           onTap: () => AppNavigator.toDesigns(),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// //
// // ----------------- SHARED WIDGETS -----------------
// //
// class SectionTitle extends StatelessWidget {
//   final String text;
//   const SectionTitle(this.text, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: GoogleFonts.poppins(
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//         color: Colors.grey.shade800,
//       ),
//     );
//   }
// }
