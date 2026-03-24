import 'package:cattle_management_system/core/localization/app_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bull_report_screen.dart';
import 'cow_report_screen.dart';
import 'deworming_report_screen.dart';
import 'heat_report_screen.dart';
import 'lab_test_report_screen.dart';
import 'medical_report_screen.dart';
import 'milk_report_screen.dart';
import 'pregnancy_report_screen.dart';
import 'vaccination_report_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          context.tr.report,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _ReportTile(
            icon: 'C',
            label: context.tr.cowReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CowReportScreen()),
            ),
          ),
          _ReportTile(
            icon: 'B',
            label: context.tr.bullReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BullReportHubScreen()),
            ),
          ),
          _ReportTile(
            icon: 'M',
            label: context.tr.milkReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MilkReportHubScreen()),
            ),
          ),
          _ReportTile(
            icon: 'H',
            label: context.tr.heatRecordReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HeatReportHubScreen()),
            ),
          ),
          _ReportTile(
            icon: 'P',
            label: context.tr.pregnancyReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PregnancyReportHubScreen(),
              ),
            ),
          ),
          _ReportTile(
            icon: 'D',
            label: context.tr.dewormingReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DewormingReportHubScreen(),
              ),
            ),
          ),
          _ReportTile(
            icon: 'Md',
            label: context.tr.medicalReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MedicalReportHubScreen()),
            ),
          ),
          _ReportTile(
            icon: 'V',
            label: context.tr.vaccinationReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const VaccinationReportHubScreen(),
              ),
            ),
          ),
          _ReportTile(
            icon: 'L',
            label: context.tr.labTestingReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LabTestReportHubScreen()),
            ),
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext ctx, String name) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF99AA5A),
        content: Text(
          ctx.tr.comingSoon(name),
          style: GoogleFonts.inter(color: Colors.white),
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _ReportTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F6F7),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              icon,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF99AA5A),
              ),
            ),
          ),
        ),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F6F7),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
