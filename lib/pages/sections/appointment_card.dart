import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppointmentCard extends StatelessWidget {
  final String title, client, date, time;

  const AppointmentCard(this.title, this.client, this.date, this.time);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        subtitle: Text(client, style: GoogleFonts.poppins()),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(date, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            Text(time, style: GoogleFonts.poppins()),
          ],
        ),
      ),
    );
  }
}
