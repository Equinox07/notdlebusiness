import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:notdle/widgets/deadline_card.dart';
import 'package:provider/provider.dart';

class DeadlineScreen extends StatefulWidget {
  const DeadlineScreen({super.key});

  static const String tag = "deadlines";

  @override
  State<DeadlineScreen> createState() => _DeadlineScreenState();
}

class _DeadlineScreenState extends State<DeadlineScreen> {
  late Future<List<Order>> _deadlinesFuture;

  @override
  void initState() {
    super.initState();
    _deadlinesFuture = _fetchDeadlines();
  }

  Future<List<Order>> _fetchDeadlines() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.fetchOrders();
    final allOrders = orderProvider.orders;

    // Filter orders with due dates and sort them
    final deadlines =
        allOrders
            .where((o) => o.dueDate != null && o.dueDate!.isNotEmpty)
            .toList();

    deadlines.sort((a, b) {
      final dateA = DateFormat("yyyy-MM-dd").parse(a.dueDate!);
      final dateB = DateFormat("yyyy-MM-dd").parse(b.dueDate!);
      return dateA.compareTo(dateB);
    });

    return deadlines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Deadlines",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: FutureBuilder<List<Order>>(
        future: _deadlinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No upcoming deadlines",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          final deadlines = snapshot.data!;
          final groupedDeadlines = _groupDeadlines(deadlines);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedDeadlines.length,
            itemBuilder: (context, index) {
              final group = groupedDeadlines[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 4,
                    ),
                    child: Text(
                      group.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  ...group.orders.map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: DeadlineCard(
                        orderFuture: Future.value(order),
                        onTap:
                            () =>
                                AppNavigator.toOrderDetails(orderId: order.id),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<_DeadlineGroup> _groupDeadlines(List<Order> orders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final overdue = <Order>[];
    final dueToday = <Order>[];
    final dueTomorrow = <Order>[];
    final upcoming = <Order>[];

    for (final order in orders) {
      try {
        final dueDate = DateFormat("yyyy-MM-dd").parse(order.dueDate!);
        final dateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

        if (dateOnly.isBefore(today)) {
          overdue.add(order);
        } else if (dateOnly.isAtSameMomentAs(today)) {
          dueToday.add(order);
        } else if (dateOnly.isAtSameMomentAs(tomorrow)) {
          dueTomorrow.add(order);
        } else {
          upcoming.add(order);
        }
      } catch (e) {
        // Ignore invalid dates
      }
    }

    final groups = <_DeadlineGroup>[];
    if (overdue.isNotEmpty) {
      groups.add(_DeadlineGroup("Overdue", overdue));
    }
    if (dueToday.isNotEmpty) {
      groups.add(_DeadlineGroup("Today", dueToday));
    }
    if (dueTomorrow.isNotEmpty) {
      groups.add(_DeadlineGroup("Tomorrow", dueTomorrow));
    }
    if (upcoming.isNotEmpty) {
      groups.add(_DeadlineGroup("Upcoming", upcoming));
    }

    return groups;
  }
}

class _DeadlineGroup {
  final String title;
  final List<Order> orders;

  _DeadlineGroup(this.title, this.orders);
}
