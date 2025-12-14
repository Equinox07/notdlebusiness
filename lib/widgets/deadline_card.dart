// lib/widgets/deadline_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/order.dart';

class DeadlineCard extends StatelessWidget {
  final Future<Order?> orderFuture;
  final VoidCallback onTap;

  const DeadlineCard({
    super.key,
    required this.orderFuture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Order?>(
      future: orderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink(); // Hide if no deadlines
        }

        final order = snapshot.data!;
        final remainingDays = _getRemainingDays(order.dueDate!);

        bool isUrgent = false;
        if (remainingDays == "Overdue" ||
            remainingDays == "Today" ||
            remainingDays == "Tomorrow") {
          isUrgent = true;
        } else {
          final days = int.tryParse(remainingDays);
          if (days != null && days <= 3) {
            isUrgent = true;
          }
        }

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      isUrgent
                          ? Colors.red.withOpacity(0.1)
                          : Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: isUrgent ? Colors.red.shade100 : Colors.grey.shade200,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    if (isUrgent)
                      Container(width: 6, color: Colors.red.shade500),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isUrgent ? 14 : 20,
                          20,
                          20,
                          20,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    isUrgent
                                        ? Colors.red.shade50
                                        : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.access_time_rounded,
                                color:
                                    isUrgent
                                        ? Colors.red.shade400
                                        : Colors.grey.shade600,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Upcoming Deadline",
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  remainingDays,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isUrgent
                                            ? Colors.red.shade600
                                            : Colors.indigo.shade600,
                                  ),
                                ),
                                Text(
                                  remainingDays == "Today" ||
                                          remainingDays == "Tomorrow" ||
                                          remainingDays == "Overdue"
                                      ? ""
                                      : "days left",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color:
                                        isUrgent
                                            ? Colors.red.shade400
                                            : Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getRemainingDays(String dueDateString) {
    try {
      final dueDate = DateFormat("yyyy-MM-dd").parse(dueDateString);
      final now = DateTime.now();

      // Normalize dates to midnight to ignore time component
      final dateOnlyDue = DateTime(dueDate.year, dueDate.month, dueDate.day);
      final dateOnlyNow = DateTime(now.year, now.month, now.day);

      final difference = dateOnlyDue.difference(dateOnlyNow).inDays;

      if (difference < 0) return "Overdue";
      if (difference == 0) return "Today";
      if (difference == 1) return "Tomorrow";

      return difference.toString();
    } catch (e) {
      return "--";
    }
  }
}
