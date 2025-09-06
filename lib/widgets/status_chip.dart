// lib/widgets/status_chip.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: statusColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green.shade600;
      case "In Progress":
        return Colors.blue.shade600;
      case "Pending":
        return Colors.orange.shade600;
      default:
        return Colors.grey;
    }
  }
}

class PaymentStatusChip extends StatelessWidget {
  final String status;
  const PaymentStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getPaymentColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payment, size: 16, color: statusColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.poppins(
              color: statusColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentColor(String status) {
    switch (status) {
      case "Full":
      case "Paid":
        return Colors.green.shade600;
      case "Partial":
        return Colors.blue.shade600;
      case "Pending":
        return Colors.orange.shade600;
      default:
        return Colors.grey;
    }
  }
}
