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
import '../../../../core/utils/app_feedback.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF99AA5A)),
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
            iconWidget: Image.asset('assets/icons/mother_cow.png', width: 26, height: 26, fit: BoxFit.contain),
            iconBgColor: const Color(0xFFF6F8EC),
            label: context.tr.cowReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CowReportScreen()),
            ),
          ),
          _ReportTile(
            iconWidget: Image.asset('assets/icons/father_cow.png', width: 26, height: 26, fit: BoxFit.contain),
            iconBgColor: const Color(0xFFF7F1EB),
            label: context.tr.bullReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BullReportHubScreen()),
            ),
          ),
          _ReportTile(
            iconWidget: Image.asset('assets/icons/milk_bottle.png', width: 26, height: 26, fit: BoxFit.contain),
            iconBgColor: const Color(0xFFFFF8E7),
            label: context.tr.milkReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MilkReportHubScreen()),
            ),
          ),
          _ReportTile(
            iconWidget: Image.asset('assets/icons/heat_record_report.png', width: 26, height: 26, fit: BoxFit.contain),
            iconBgColor: const Color(0xFFFFF0F5),
            label: context.tr.heatRecordReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HeatReportHubScreen()),
            ),
          ),
          _ReportTile(
            iconWidget: Image.asset('assets/icons/pregnancy_report.png', width: 26, height: 26, fit: BoxFit.contain),
            iconBgColor: const Color(0xFFE8FAF0),
            label: context.tr.pregnancyReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PregnancyReportHubScreen(),
              ),
            ),
          ),
          _ReportTile(
            iconWidget: Image.asset('assets/icons/deworming.png', width: 26, height: 26, fit: BoxFit.contain),
            iconBgColor: const Color(0xFFF3F7EC),
            label: context.tr.dewormingReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DewormingReportHubScreen(),
              ),
            ),
          ),
          _ReportTile(
            iconWidget: Image.asset('assets/icons/medical.png', width: 26, height: 26, fit: BoxFit.contain),
            iconBgColor: const Color(0xFFFFEBEB),
            label: context.tr.medicalReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MedicalReportHubScreen()),
            ),
          ),
          _ReportTile(
            iconWidget: Image.asset('assets/icons/vaccine.png', width: 26, height: 26, fit: BoxFit.contain),
            iconBgColor: const Color(0xFFEDF3FF),
            label: context.tr.vaccinationReport,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const VaccinationReportHubScreen(),
              ),
            ),
          ),
          _ReportTile(
            iconWidget: const Icon(Icons.science_rounded, color: Colors.indigo, size: 26),
            iconBgColor: const Color(0xFFF0F2FD),
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
    AppFeedback.showSuccess(ctx, 
          ctx.tr.comingSoon(name),
        );
  }
}

class _ReportTile extends StatelessWidget {
  final Widget iconWidget;
  final Color iconBgColor;
  final String label;
  final VoidCallback onTap;

  const _ReportTile({
    required this.iconWidget,
    required this.iconBgColor,
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
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: iconWidget,
          ),
        ),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.12),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.chevron_right, size: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
