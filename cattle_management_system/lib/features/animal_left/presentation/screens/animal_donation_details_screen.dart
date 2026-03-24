import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimalDonationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> record;
  const AnimalDonationDetailsScreen({super.key, required this.record});

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
          '${record['type'] ?? 'Bull'} Details',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Animal Image Box
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F3EE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/bull_illustration.png', // Fallback to an illustration
                  width: 120,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.pets,
                    size: 80,
                    color: Color(0xFF8B5A2B),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tag Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Text(
                    record['tagNo'] ?? '132',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.female,
                    size: 16,
                    color: Colors.grey,
                  ), // Just icon like image
                  const Spacer(),
                  Text(
                    'No: -',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Detail Fields
            _DetailTile(label: 'Date of Birth', value: '-'),
            _DetailTile(label: 'Acquisition', value: '-'),
            _DetailTile(
              label: 'Mother Name',
              value: 'Show Pedigree',
              isAction: true,
            ),
            _DetailTile(
              label: 'Father Name',
              value: 'Show Pedigree',
              isAction: true,
            ),
            _DetailTile(label: 'Bull Now', value: '-'),
            _DetailTile(label: 'Mother Milk', value: '-'),
            _DetailTile(label: 'Grandmother Milk', value: '-'),

            const SizedBox(height: 24),

            // List of sections
            _SectionItem(
              label: 'Child',
              icon: Icons.child_care,
              color: Colors.green.shade100,
              iconColor: Colors.green,
            ),
            _SectionItem(
              label: 'Medical',
              icon: Icons.medical_services_outlined,
              color: Colors.red.shade50,
              iconColor: Colors.red,
            ),
            _SectionItem(
              label: 'Vaccination',
              icon: Icons.vaccines_outlined,
              color: Colors.blue.shade50,
              iconColor: Colors.blue,
            ),
            _SectionItem(
              label: 'Deworming',
              icon: Icons.bug_report_outlined,
              color: Colors.green.shade50,
              iconColor: Colors.green.shade700,
            ),
            _SectionItem(
              label: 'Lab Testing',
              icon: Icons.biotech_outlined,
              color: Colors.purple.shade50,
              iconColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isAction;

  const _DetailTile({
    required this.label,
    required this.value,
    this.isAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isAction ? const Color(0xFF99AA5A) : Colors.grey,
                fontWeight: isAction ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _SectionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
