// lib/screens/dashboard_home.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/db/database_helper.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:notdle/providers/dashboard_provider.dart';
import 'package:notdle/providers/notification_provider.dart';
import 'package:notdle/services/session_manager.dart';
import 'package:notdle/widgets/deadline_card.dart';
import 'package:provider/provider.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashBoardProvider>(context, listen: false).fetchCounts();
      Provider.of<CompanyProvider>(context, listen: false).fetchCompany();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashBoardProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final order = dashboardProvider.soonestDueOrder;
    final companyProvider = Provider.of<CompanyProvider>(context);

    final companyName = companyProvider.company?.businessName ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Dashboard"),
        automaticallyImplyLeading: false,
        actions: [
          _NotificationBell(notificationProvider: notificationProvider),
          const SizedBox(width: 8),
          _ProfileIcon(),
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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade600, Colors.indigo.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome,',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                // Replace with your company name or user name
                                companyName,
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add a decorative icon or image
                        const Icon(
                          Icons.business_center,
                          size: 40,
                          color: Colors.white54,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Here's what you need to know today.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // ➡️ Refactored Welcome Section
              // FutureBuilder<Company?>(
              //   future: SessionManager.getCompany(),
              //   builder: (context, snapshot) {
              //     final companyName = snapshot.data?.businessName ?? 'your business';
              //     return Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           'Good morning,',
              //           style: GoogleFonts.poppins(
              //             fontSize: 24,
              //             fontWeight: FontWeight.w500,
              //             color: Colors.grey.shade600,
              //           ),
              //         ),
              //         Text(
              //           companyName,
              //           style: GoogleFonts.poppins(
              //             fontSize: 28,
              //             fontWeight: FontWeight.bold,
              //             color: Colors.black87,
              //           ),
              //         ),
              //         const SizedBox(height: 4),
              //         Text(
              //           "Here's what's happening today.",
              //           style: GoogleFonts.poppins(
              //             fontSize: 16,
              //             color: Colors.grey.shade500,
              //           ),
              //         ),
              //       ],
              //     );
              //   },
              // ),

              const SizedBox(height: 26),

              // ➡️ Insight Cards Section
              _SectionTitle(text: "Total Insights"),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return _InsightCard(
                        title: 'Orders',
                        count: dashboardProvider.orderCount,
                        icon: Icons.shopping_bag_outlined,
                        iconColor: Colors.indigo.shade600,
                      );
                    case 1:
                      return _InsightCard(
                        title: 'Customers',
                        count: dashboardProvider.customerCount,
                        icon: Icons.people_outline,
                        iconColor: Colors.green.shade600,
                      );
                    case 2:
                      return _InsightCard(
                        title: 'Invoices',
                        count: 0,
                        icon: Icons.receipt_long,
                        iconColor: Colors.orange.shade600,
                      );
                    case 3:
                      return _InsightCard(
                        title: 'Designs',
                        count: 0,
                        icon: Icons.palette_outlined,
                        iconColor: Colors.purple.shade600,
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),

              const SizedBox(height: 32),

              // ➡️ Quick Actions Section
              _SectionTitle(text: "Quick Actions"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _ActionCard(
                    title: 'New Client',
                    icon: Icons.person_add_alt,
                    onTap: () => AppNavigator.toAddCustomer(),
                  ),
                  _ActionCard(
                    title: 'New Order',
                    icon: Icons.add_circle_outline,
                    onTap: () => AppNavigator.toCreateNewOrder(),
                  ),
                  _ActionCard(
                    title: 'New Invoice',
                    icon: Icons.add_to_photos_outlined,
                    onTap: () => AppNavigator.toCreateNewOrder(),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ➡️ Deadlines Section
              _SectionTitle(text: "Recent Deadlines"),
              const SizedBox(height: 12),
              // Use a StreamBuilder to get real-time order data
              if (order != null)
                DeadlineCard(orderFuture: DatabaseHelper.instance.getSoonestDueOrder(), onTap: () {  },)
              else
                Center(
                  child: Text(
                    'No upcoming deadlines.',
                    style: GoogleFonts.poppins(color: Colors.grey.shade600),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ➡️ Reusable Widgets

// Notification Bell with Count
class _NotificationBell extends StatelessWidget {
  final NotificationProvider notificationProvider;

  const _NotificationBell({required this.notificationProvider});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black54),
          onPressed: () => AppNavigator.toNotifications(),
        ),
        if (notificationProvider.unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                notificationProvider.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// Profile Icon
class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.account_circle, color: Colors.black87),
      onPressed: () => AppNavigator.toProfile(),
    );
  }
}

// Section Title
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

// ➡️ Reusable Card Widgets
class _InsightCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color iconColor;

  const _InsightCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: iconColor, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
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
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.indigo.shade600, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder for DeadlineCard
// class DeadlineCard extends StatelessWidget {
//   final Order order;
//   const DeadlineCard({super.key, required this.order});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         title: Text("Order Due: ${order.title}"),
//         subtitle: Text("Delivery Date: ${order.dueDate}"),
//       ),
//     );
//   }
// }




// // Assume this exists
//
// class DashboardHome extends StatefulWidget {
//   const DashboardHome({super.key});
//
//   @override
//   State<DashboardHome> createState() => _DashboardHomeState();
// }
//
// class _DashboardHomeState extends State<DashboardHome> {
//   late Future<Company?> _companyFuture;
//   final DatabaseHelper _dbHelper = DatabaseHelper.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     _companyFuture = SessionManager.getCompany();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<DashBoardProvider>(context, listen: false).fetchCounts();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     //Listen for latest updates
//     final dashboardProvider = Provider.of<DashBoardProvider>(context);
//     final notificationProvider = Provider.of<NotificationProvider>(context);
//
//     final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
//
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
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
//               style: GoogleFonts.poppins(
//                 fontSize: 12,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           // ➡️ Wrap the notification icon and its count in a Stack
//           Stack(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.notifications_none),
//                 onPressed: () => AppNavigator.toNotifications(),
//               ),
//               Positioned(
//                 right: 8,
//                 top: 8,
//                 child: Container(
//                   padding: const EdgeInsets.all(2),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   constraints: const BoxConstraints(
//                     minWidth: 16,
//                     minHeight: 16,
//                   ),
//                   child: const Text(
//                     '3', // Dynamic count
//                     style: TextStyle(color: Colors.white, fontSize: 10),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           // The account icon remains separate
//           IconButton(
//             icon: const Icon(Icons.account_circle, color: Colors.black87),
//             onPressed: () => AppNavigator.toProfile(),
//           ),
//         ],
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(isTablet ? 24 : 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Welcome Section
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.indigo.shade600, Colors.indigo.shade800],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Good morning, 👋',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     "Here's what's happening with your business.",
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 14,
//                                       color: Colors.white70,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const CircleAvatar(
//                               backgroundColor: Colors.white30,
//                               radius: 30,
//                               child: Icon(
//                                 Icons.person,
//                                 size: 30,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 26),
//
//               GridView.count(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 crossAxisCount: isTablet ? 3 : 2,
//                 crossAxisSpacing: isTablet ? 20 : 16,
//                 mainAxisSpacing: isTablet ? 20 : 16,
//                 childAspectRatio: isTablet ? 1.2 : 1.4,
//                 children: [
//                   _InsightCard(
//                     title: 'Orders',
//                     count: 0,
//                     icon: Icons.shopping_bag_outlined,
//                     iconColor: Colors.indigo.shade600,
//                   ),
//                   _InsightCard(
//                     title: 'Customers',
//                     count: 0,
//                     icon: Icons.people_outline,
//                     iconColor: Colors.green.shade600,
//                   ),
//                   _InsightCard(
//                     title: 'Invoices',
//                     count: 0,
//                     icon: Icons.receipt_long,
//                     iconColor: Colors.orange.shade600,
//                   ),
//                   _InsightCard(
//                     title: 'Designs',
//                     count: 0,
//                     icon: Icons.palette_outlined,
//                     iconColor: Colors.purple.shade600,
//                   ),
//                 ],
//               ),
//
//               // const SizedBox(height: 32),
//               // _SectionTitle(text: "Deadlines"),
//               const SizedBox(height: 12),
//               DeadlineCard(
//                 orderFuture: DatabaseHelper.instance.getSoonestDueOrder(),
//                 onTap: () => debugPrint("Orders"),
//               ),
//
//               const SizedBox(height: 12),
//
//               _SectionTitle(text: "Quick Actions"),
//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ActionCard(
//                     title: 'New Client',
//                     icon: Icons.person_add_alt,
//                     onTap: () => AppNavigator.toAddCustomer(),
//                   ),
//
//                   const SizedBox(width: 10),
//                   ActionCard(
//                     title: 'New Order',
//                     icon: Icons.add_circle_outline,
//                     onTap: () => AppNavigator.toCreateNewOrder(),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // The new, visually distinct card for appointments
// class _AppointmentFocusCard extends StatelessWidget {
//   final String title;
//   final String customerName;
//   final String time;
//
//   const _AppointmentFocusCard({
//     required this.title,
//     required this.customerName,
//     required this.time,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2C3E50), // A dark, professional blue
//         borderRadius: BorderRadius.circular(20),
//         gradient: const LinearGradient(
//           colors: [Color(0xFF2C3E50), Color(0xFF4A607C)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(Icons.calendar_today, color: Colors.white, size: 28),
//           const SizedBox(width: 20),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   time,
//                   style: GoogleFonts.poppins(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   title,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white.withOpacity(0.9),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   customerName,
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
//         ],
//       ),
//     );
//   }
// }
//
// class _SectionTitle extends StatelessWidget {
//   final String text;
//   const _SectionTitle({super.key, required this.text});
//
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: GoogleFonts.poppins(
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//         color: Colors.grey.shade800,
//       ),
//     );
//   }
// }
//
// class _QuickStatCard extends StatelessWidget {
//   final String value;
//   final String label;
//   final Color color;
//   final bool isTablet;
//
//   const _QuickStatCard({
//     required this.value,
//     required this.label,
//     required this.color,
//     required this.isTablet,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 20 : 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: isTablet ? 32 : 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.blue.shade600,
//             ),
//           ),
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               color: Colors.grey,
//               fontSize: isTablet ? 14 : 12,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _HomeMenuCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;
//
//   const _HomeMenuCard({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.color,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 36, color: color),
//               const SizedBox(height: 12),
//               Text(
//                 title,
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade800,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 subtitle,
//                 style: GoogleFonts.poppins(
//                   fontSize: 12,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // lib/screens/dashboard_screen.dart (inside the file with DashboardScreen)
//
// // ... other existing widgets and imports
// // lib/screens/dashboard_screen.dart
//
// class _InsightCard extends StatelessWidget {
//   final String title;
//   final int count;
//   final IconData icon;
//   final Color iconColor;
//
//   const _InsightCard({
//     required this.title,
//     required this.count,
//     required this.icon,
//     required this.iconColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // ➡️ Wrap the title in Flexible to prevent overflow
//                 Flexible(
//                   child: Text(
//                     title,
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade600,
//                     ),
//                     maxLines: 1, // Ensure it doesn't wrap to multiple lines
//                     overflow:
//                         TextOverflow.ellipsis, // Add ellipses for long text
//                   ),
//                 ),
//                 Icon(icon, color: iconColor, size: 28),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               count.toString(),
//               style: GoogleFonts.poppins(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// // ActionCard(title: "New Client", icon: Icons.person, onTap: () => {}),
// // Next Appointment Section
// // _SectionTitle(text: "Your Next Appointment"),
// // const SizedBox(height: 12),
// // _AppointmentFocusCard(
// //   title: "Fitting - Wedding Dress",
// //   customerName: "Emma Johnson",
// //   time: "2:30 PM",
// // ),
