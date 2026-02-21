// lib/screens/services_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/service_model.dart';
import 'package:notdle/screens/all_measurement_screen.dart';
// Your navigation destinations

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const String tag = "services";

  final List<ServiceModel> _services = const [
    ServiceModel(
      title: 'Customers',
      description: 'Manage clients profiles',
      icon: Icons.people_outline,
      iconColor: Colors.blue,
    ),
    ServiceModel(
      title: 'Measurements',
      description: 'Manage and update client measurements',
      icon: Icons.straighten,
      iconColor: Colors.orange,
    ),
    ServiceModel(
      title: 'Orders',
      description: 'Track progress and status of all orders',
      icon: Icons.shopping_bag_outlined,
      iconColor: Colors.green,
    ),
    ServiceModel(
      title: 'Designs',
      description: 'View and manage your design catalog',
      icon: Icons.palette_outlined,
      iconColor: Colors.purple,
      isComingSoon: true,
    ),
    ServiceModel(
      title: 'Repairs',
      description: 'Log and track clothing repair jobs',
      icon: Icons.handyman_outlined,
      iconColor: Colors.red,
      isComingSoon: true,
    ),
    ServiceModel(
      title: 'Appointments',
      description: 'Manage client bookings',
      icon: Icons.calendar_today_outlined,
      iconColor: Colors.teal,
      isComingSoon: true,
    ),
    ServiceModel(
      title: 'myStore',
      description: 'Manage your online shop',
      icon: Icons.storefront_outlined,
      iconColor: Colors.indigo,
      isComingSoon: true,
    ),
    ServiceModel(
      title: 'Fabrics',
      description: 'Catalogue of your materials',
      icon: Icons.texture_outlined,
      iconColor: Colors.amber,
      isComingSoon: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

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
          "Services",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Business Services",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Manage your shop operations efficiently",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 3 : 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final service = _services[index];
                return _ServiceCard(
                  service: service,
                  onTap: () {
                    if (service.isComingSoon) return;
                    switch (service.title) {
                      case 'Customers':
                        debugPrint("Service clicked ${service.title}");
                        break;
                      case 'Measurements':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllMeasurementScreen(),
                          ),
                        );
                        break;
                      default:
                        debugPrint("Service clicked ${service.title}");
                    }
                  },
                );
              }, childCount: _services.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: service.iconColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: service.isComingSoon ? null : onTap,
          borderRadius: BorderRadius.circular(28),
          child: Opacity(
            opacity: service.isComingSoon ? 0.6 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: service.iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          service.icon,
                          size: 22,
                          color: service.iconColor,
                        ),
                      ),
                      if (service.isComingSoon)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Soon",
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    service.title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1C1E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
