import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/health_event.dart';

class MedicalDetailsScreen extends StatelessWidget {
  final HealthEvent record;

  const MedicalDetailsScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final statusColor = record.medicalStatus == 'Healthy'
        ? const Color(0xFF99AA5A)
        : Colors.red;
    final statusBg = record.medicalStatus == 'Healthy'
        ? const Color(0xFFF1F8E9)
        : const Color(0xFFFFEBEE);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          'Medical Information',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/icons/father_cow.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.pets,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    record.cowName,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ',
                                  style: TextStyle(color: Colors.grey.shade400),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    record.medicalStatus ?? 'Healthy',
                                    style: GoogleFonts.inter(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F3D3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.bookmark,
                                        color: Color(0xFFC49A2D),
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Tag No : ${record.cowTagNumber}',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFFC49A2D),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'No. : ${record.cowSerialNumber}',
                                  style: GoogleFonts.inter(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  _InfoDetailRow(
                    icon: Icons.sync,
                    label: 'Visit Type:',
                    value: record.visitType ?? 'General Check-up',
                    iconColor: const Color(0xFF5C9DCE),
                    iconBg: const Color(0xFFE3F2FD),
                  ),
                  const SizedBox(height: 16),
                  _InfoDetailRow(
                    icon: Icons.coronavirus_outlined,
                    label: 'Disease:',
                    value: record.disease ?? '-',
                    iconColor: Colors.grey,
                    iconBg: const Color(0xFFF5F5F5),
                  ),
                  const SizedBox(height: 16),
                  _InfoDetailRow(
                    icon: Icons.person_outline,
                    label: 'Doctor Name:',
                    value: record.doctorName ?? '-',
                    iconColor: const Color(0xFF99AA5A),
                    iconBg: const Color(0xFFF1F8E9),
                  ),
                  const SizedBox(height: 16),
                  _InfoDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Visit Date:',
                    value: DateFormat('dd MMM, yyyy').format(record.eventDate),
                    iconColor: const Color(0xFF5C9DCE),
                    iconBg: const Color(0xFFE3F2FD),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sections
            _DetailSectionTile(
              icon: Icons.medical_services_outlined,
              label: 'Symptoms',
              iconColor: Colors.orange,
              iconBg: const Color(0xFFFFF3E0),
              subtitle: record.symptoms ?? 'No symptoms recorded',
            ),
            const SizedBox(height: 16),
            _DetailSectionTile(
              icon: Icons.opacity,
              label: 'Treatment',
              iconColor: Colors.green,
              iconBg: const Color(0xFFE8F5E9),
              subtitle: record.treatment ?? 'No treatment recorded',
            ),
            const SizedBox(height: 16),
            _DetailSectionTile(
              icon: Icons.wb_sunny_outlined,
              label: 'Rescue Procedure',
              iconColor: Colors.red,
              iconBg: const Color(0xFFFFEBEE),
              subtitle: record.rescueProcedure ?? 'No procedure recorded',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBg;

  const _InfoDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailSectionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBg;
  final String subtitle;

  const _DetailSectionTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBg,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
