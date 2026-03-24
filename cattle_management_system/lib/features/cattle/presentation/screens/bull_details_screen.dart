import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/cattle.dart';
import 'cattle_details/cow_pedigree_screen.dart';
import 'cattle_details/cattle_record_screen.dart';
import 'cattle_details/cow_child_list_screen.dart';

class BullDetailsScreen extends StatelessWidget {
  final Cattle cattle;

  const BullDetailsScreen({super.key, required this.cattle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Bull Details',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle:
            false, // As per image (left aligned back button, title next to it? Image shows Title centered? No, image has title next to back arrow "Bull Details")
        // Screenshot 1: Back < arrow, "Bull Details" text next to it.
        // Actually flutter default is Title next to back button if centerTitle is false.
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildBullHeader(cattle),
            const SizedBox(height: 24),

            // Details
            _buildDetailField(
              'Date of Birth',
              DateFormat('dd MMM, yyyy').format(cattle.dateOfBirth),
            ),
            _buildDetailField('Acquisition', cattle.acquisitionType ?? 'Birth'),
            _buildDetailField(
              'Mother Name',
              cattle.motherName ?? 'Not Specified',
            ),
            _buildDetailField(
              'Father Name',
              cattle.fatherName ?? 'Not Specified',
              isLink: cattle.fatherId != null,
              highlightText: cattle.fatherId != null,
              onTap: cattle.fatherId == null
                  ? null
                  : () {
                      // Open Pedigree or dummy
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => CowPedigreeScreen(
                            cattle: cattle,
                            title: 'Father Pedigree',
                          ),
                        ),
                      );
                    },
            ),
            _buildDetailField('Bull View', cattle.bullView ?? '-'),
            _buildDetailField(
              'Mother Milk',
              cattle.motherMilk != null ? '${cattle.motherMilk} Ltr.' : '-',
            ),
            _buildDetailField(
              'Grandmother Milk',
              cattle.grandmotherMilk != null
                  ? '${cattle.grandmotherMilk} Ltr.'
                  : '-',
            ),

            const SizedBox(height: 24),

            // Action Buttons
            _buildRecordButton(
              context,
              'Child',
              Icons.child_care_rounded,
              Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CowChildListScreen(parentCattle: cattle),
                ),
              ),
            ),
            _buildRecordButton(
              context,
              'Medical',
              Icons.medical_services_rounded,
              Colors.red,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CowRecordScreen(
                    cattle: cattle,
                    title: 'Medical Records',
                    icon: Icons.medical_services,
                  ),
                ),
              ),
            ),
            _buildRecordButton(
              context,
              'Vaccination',
              Icons.vaccines_rounded,
              Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CowRecordScreen(
                    cattle: cattle,
                    title: 'Vaccination',
                    icon: Icons.vaccines,
                  ),
                ),
              ),
            ),
            _buildRecordButton(
              context,
              'Deworming',
              Icons.spa_rounded,
              Colors.lightGreen,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CowRecordScreen(
                    cattle: cattle,
                    title: 'Deworming',
                    icon: Icons.bug_report,
                  ),
                ),
              ),
            ),
            _buildRecordButton(
              context,
              'Lab Testing',
              Icons.biotech_rounded,
              Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CowRecordScreen(
                    cattle: cattle,
                    title: 'Lab Testing',
                    icon: Icons.science,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullHeader(Cattle cattle) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: (cattle.imageUrl != null && cattle.imageUrl!.isNotEmpty)
            ? DecorationImage(
                image: NetworkImage(cattle.imageUrl!),
                fit: BoxFit.cover,
              )
            : const DecorationImage(
                image: AssetImage(
                  'assets/images/bull_placeholder.png',
                ), // Or generic
                fit: BoxFit.cover,
              ),
        color: Colors.grey.shade200,
      ),
      child: Stack(
        children: [
          if (cattle.imageUrl == null || cattle.imageUrl!.isEmpty)
            Center(child: Icon(Icons.pets, size: 60, color: Colors.brown[300])),

          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    cattle.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4), // Light Yellow
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sell, size: 12, color: Colors.brown),
                        const SizedBox(width: 4),
                        Text(
                          'Tag No : ${cattle.tagNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No. : ${cattle.serialNumber ?? "1001"}',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField(
    String label,
    String value, {
    bool isLink = false,
    bool highlightText = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7), // Light grey bg
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: highlightText
                      ? const Color(0xFFA4C639)
                      : Colors.black87, // Greenishly olive for links
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordButton(
    BuildContext context,
    String title,
    IconData icon,
    MaterialColor color, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

