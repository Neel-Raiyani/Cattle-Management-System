import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ear_tag_alert_screen.dart';
import 'generic_alert_screen.dart';

class AlertHubScreen extends StatelessWidget {
  const AlertHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
        ),
        title: Text(
          'Alert',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AlertTile(
            label: 'Ear Tag No. Alert',
            icon: Icons.sell_outlined,
            iconColor: Colors.grey,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EarTagAlertScreen()),
            ),
          ),
          _AlertTile(
            label: 'Adult Alert',
            icon: Icons.pets,
            iconColor: const Color(0xFF99AA5A),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GenericAlertScreen(
                  title: 'Adult Alert',
                  alertType: 'adult',
                  icon: Icons.pets,
                  iconColor: Color(0xFF99AA5A),
                ),
              ),
            ),
          ),
          _AlertTile(
            label: 'Heat Alert',
            icon: Icons.favorite,
            iconColor: Colors.pink,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GenericAlertScreen(
                  title: 'Heat Alert',
                  alertType: 'heat',
                  icon: Icons.favorite,
                  iconColor: Colors.pink,
                ),
              ),
            ),
          ),
          _AlertTile(
            label: 'Pregnancy Checking Alert',
            icon: Icons.pregnant_woman,
            iconColor: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GenericAlertScreen(
                  title: 'Pregnancy Checking Alert',
                  alertType: 'pregnancy-check',
                  icon: Icons.pregnant_woman,
                  iconColor: Colors.green,
                ),
              ),
            ),
          ),
          _AlertTile(
            label: 'Insemination Alert',
            icon: Icons.biotech,
            iconColor: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GenericAlertScreen(
                  title: 'Insemination Alert',
                  alertType: 'insemination',
                  icon: Icons.biotech,
                  iconColor: Colors.teal,
                ),
              ),
            ),
          ),
          _AlertTile(
            label: 'Delivery Alert',
            icon: Icons.favorite_border,
            iconColor: Colors.red,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GenericAlertScreen(
                  title: 'Delivery Alert',
                  alertType: 'delivery',
                  icon: Icons.favorite_border,
                  iconColor: Colors.red,
                ),
              ),
            ),
          ),
          _AlertTile(
            label: 'Vaccination Alert',
            icon: Icons.colorize,
            iconColor: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GenericAlertScreen(
                  title: 'Vaccination Alert',
                  alertType: 'vaccination',
                  icon: Icons.colorize,
                  iconColor: Colors.blue,
                ),
              ),
            ),
          ),
          _AlertTile(
            label: 'Deworming Alert',
            icon: Icons.spa,
            iconColor: Colors.lightGreen,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GenericAlertScreen(
                  title: 'Deworming Alert',
                  alertType: 'deworming',
                  icon: Icons.spa,
                  iconColor: Colors.lightGreen,
                ),
              ),
            ),
          ),
          _AlertTile(
            label: 'Lab Checking Alert',
            icon: Icons.science,
            iconColor: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GenericAlertScreen(
                  title: 'Lab Checking Alert',
                  alertType: 'lab-test',
                  icon: Icons.science,
                  iconColor: Colors.purple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _AlertTile({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        trailing: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
