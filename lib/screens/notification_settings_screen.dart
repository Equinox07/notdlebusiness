import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/widgets/custom_app_bar.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  static const String tag = "notification_settings_screen";

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Order Updates
  bool _fittings = true;
  bool _statusChanges = true;
  bool _deadlines = false;

  // Client Communications
  bool _newMessages = true;
  bool _meetingReminders = true;

  // Marketing & Billing
  bool _billingReports = false;
  bool _promotionTips = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Notifications",
        centerTitle: true,
        isLight: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildSection(
              title: "Order Updates",
              items: [
                _buildToggleItem(
                  "Fittings",
                  "Scheduled or rescheduled fitting alerts",
                  _fittings,
                  (val) => setState(() => _fittings = val),
                  isLast: false,
                ),
                _buildToggleItem(
                  "Status Changes",
                  "Garment construction progress updates",
                  _statusChanges,
                  (val) => setState(() => _statusChanges = val),
                  isLast: false,
                ),
                _buildToggleItem(
                  "Deadlines",
                  "Delivery and milestone reminders",
                  _deadlines,
                  (val) => setState(() => _deadlines = val),
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: "Client Communications",
              items: [
                _buildToggleItem(
                  "New Messages",
                  "Direct messages from clients",
                  _newMessages,
                  (val) => setState(() => _newMessages = val),
                  isLast: false,
                ),
                _buildToggleItem(
                  "Meeting Reminders",
                  "Alerts before scheduled appointments",
                  _meetingReminders,
                  (val) => setState(() => _meetingReminders = val),
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: "Marketing & Billing",
              items: [
                _buildToggleItem(
                  "Billing Reports",
                  "Weekly financial summaries",
                  _billingReports,
                  (val) => setState(() => _billingReports = val),
                  isLast: false,
                ),
                _buildToggleItem(
                  "Promotion & Tips",
                  "New features and business growth tips",
                  _promotionTips,
                  (val) => setState(() => _promotionTips = val),
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PREFERENCES",
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6200EE),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "StitchFlow Alerts",
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Manage how you stay updated with your fashion business operations.",
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF6200EE),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(color: Colors.grey.shade100, thickness: 1, height: 24),
      ],
    );
  }
}
