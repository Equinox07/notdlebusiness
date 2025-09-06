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
          return const Center(child: Text("Error fetching deadline."));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink(); // Hide if no deadlines
        }

        final order = snapshot.data!;
        final remainingDays = _getRemainingDays(order.dueDate!);

        return InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.watch_later_outlined,
                  color: Colors.red.shade600,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Deadline",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      remainingDays,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade600,
                      ),
                    ),
                    Text(
                      "days left",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
              ],
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
      final difference = dueDate.difference(now);
      return difference.inDays.toString();
    } catch (e) {
      return "--";
    }
  }
}
