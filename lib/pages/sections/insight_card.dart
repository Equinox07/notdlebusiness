import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class InsightCard extends StatelessWidget {
  final String title, value, subtitle;
  final IconData icon;
  final Color iconColor;

  const InsightCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Spacer(),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: GoogleFonts.poppins(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
