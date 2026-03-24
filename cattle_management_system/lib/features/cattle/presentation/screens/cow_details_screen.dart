// fl_chart import removed
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// localized strings import removed
import '../../domain/entities/cattle.dart';
import 'cattle_details/cow_child_list_screen.dart';
import 'cattle_details/cow_milk_production_screen.dart';
import 'cattle_details/cow_parity_screen.dart';
import 'cattle_details/cattle_record_screen.dart';

class CowDetailsScreen extends StatefulWidget {
  final Cattle cattle;

  const CowDetailsScreen({super.key, required this.cattle});

  @override
  State<CowDetailsScreen> createState() => _CowDetailsScreenState();
}

class _CowDetailsScreenState extends State<CowDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    // Localization would be used here, but for now we follow the design text
    // final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Cow Details',
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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header with Image and Overlay Info
            _buildCowHeader(),

            const SizedBox(height: 24),

            // 2. Basic Info Fields
            _buildDetailField(
              'Birth Date',
              DateFormat('dd MMM yyyy').format(widget.cattle.dateOfBirth),
            ),
            _buildDetailField('Age', widget.cattle.displayAge),
            _buildDetailField('Type', widget.cattle.status, highlight: true),
            _buildDetailField('Cow Type', widget.cattle.breed),
            _buildDetailField(
              'Pregnant',
              widget.cattle.isPregnant == true ? 'Yes' : 'No',
            ),
            // 3. Udder Status
            const SizedBox(height: 16),
            Text(
              'Udder',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildUdderIcon(widget.cattle.isUdderClosedFL == true),
                _buildUdderIcon(widget.cattle.isUdderClosedFR == true),
                _buildUdderIcon(widget.cattle.isUdderClosedBL == true),
                _buildUdderIcon(widget.cattle.isUdderClosedBR == true),
              ],
            ),

            // 4. Acquisition & Lineage
            const SizedBox(height: 16),
            _buildDetailField(
              'Acquisition',
              widget.cattle.acquisitionType ?? 'Born at Farm',
            ),
            _buildDetailField(
              'Mother Name',
              widget.cattle.motherName ?? 'Not Specified',
              isLink: widget.cattle.motherId != null,
              onTap: widget.cattle.motherId == null
                  ? null
                  : () {
                      // Navigate to Mother's pedigree or details if possible
                    },
            ),
            _buildDetailField(
              'Father Name',
              widget.cattle.fatherName ?? 'Not Specified',
              isLink: widget.cattle.fatherId != null,
              onTap: widget.cattle.fatherId == null
                  ? null
                  : () {
                      // Navigate to Father's pedigree
                    },
            ),

            // 5. Purchase Details Section (Conditional)
            if (widget.cattle.acquisitionType?.toUpperCase() == 'PURCHASE') ...[
              const SizedBox(height: 24),
              Text(
                'Purchase Details',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailField(
                'Purchase Date',
                widget.cattle.purchaseDate != null
                    ? DateFormat('dd MMM, yyyy').format(widget.cattle.purchaseDate!)
                    : '-',
              ),
              _buildDetailField('Owner Name', widget.cattle.ownerName ?? '-'),
              _buildDetailField(
                'Mobile No.',
                widget.cattle.ownerMobile ?? '-',
              ),
              _buildDetailField(
                'Price',
                widget.cattle.purchasePrice != null
                    ? '₹ ${widget.cattle.purchasePrice}/-'
                    : '-',
              ),
              _buildDetailField(
                'Purchased From',
                widget.cattle.purchasedFrom ?? '-',
              ),
            ],

            const SizedBox(height: 24),

            // 6. Record Buttons (Vertical List)
            _buildRecordButton(
              'Milk Details',
              'assets/icons/milk_bottle.png', // Fallback to icon if no asset
              Icons.water_drop_outlined,
              Colors.orange.shade100,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CowMilkProductionScreen(cattle: widget.cattle),
                ),
              ),
            ),
            _buildRecordButton(
              'Parity Details',
              '',
              Icons.timer_outlined,
              Colors.blueGrey.shade100,
              Colors.blueGrey,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CowParityScreen(cattle: widget.cattle),
                ),
              ),
            ),
            _buildRecordButton(
              'Child',
              '',
              Icons.child_care,
              Colors.green.shade100,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CowChildListScreen(parentCattle: widget.cattle),
                  ),
                );
              },
            ),
            _buildRecordButton(
              'Medical',
              '',
              Icons.medical_services_outlined,
              Colors.red.shade100,
              Colors.red,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CowRecordScreen(
                    cattle: widget.cattle,
                    title: 'Medical Records',
                    icon: Icons.medical_services,
                  ),
                ),
              ),
            ),
            _buildRecordButton(
              'Vaccination',
              '',
              Icons.vaccines_outlined,
              Colors.blue.shade100,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CowRecordScreen(
                    cattle: widget.cattle,
                    title: 'Vaccination',
                    icon: Icons.vaccines,
                  ),
                ),
              ),
            ),
            _buildRecordButton(
              'Deworming',
              '',
              Icons.coronavirus_outlined, // Closest to bug/virus
              Colors.lightGreen.shade100,
              Colors.lightGreen,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CowRecordScreen(
                    cattle: widget.cattle,
                    title: 'Deworming',
                    icon: Icons.bug_report,
                  ),
                ),
              ),
            ),
            _buildRecordButton(
              'Lab Testing',
              '',
              Icons.science_outlined,
              Colors.purple.shade100,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CowRecordScreen(
                    cattle: widget.cattle,
                    title: 'Lab Testing',
                    icon: Icons.science,
                  ),
                ),
              ),
            ),
            _buildRecordButton(
              'Heat Record',
              '',
              Icons.favorite_border,
              Colors.pink.shade100,
              Colors.pink,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CowRecordScreen(
                    cattle: widget.cattle,
                    title: 'Heat Records',
                    icon: Icons.local_fire_department,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCowHeader() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image:
            (widget.cattle.imageUrl != null &&
                widget.cattle.imageUrl!.isNotEmpty)
            ? DecorationImage(
                image: NetworkImage(widget.cattle.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
        color: Colors.orange.shade50, // Fallback color
      ),
      child: Stack(
        children: [
          if (widget.cattle.imageUrl == null || widget.cattle.imageUrl!.isEmpty)
            const Center(
              child: Icon(Icons.pets, size: 60, color: Colors.orange),
            ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    widget.cattle.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1), // Light Yellow
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sell, size: 14, color: Colors.brown),
                        const SizedBox(width: 4),
                        Text(
                          'Tag No : ${widget.cattle.tagNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
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
    bool highlight = false,
    bool isLink = false,
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
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: isLink ? onTap : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: highlight
                      ? Colors.orange
                      : (isLink ? Colors.green : Colors.black87),
                  fontWeight: isLink || highlight
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUdderIcon(bool isClosed) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: isClosed ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isClosed ? Colors.red : Colors.green,
          width: 1,
        ),
      ),
      child: Icon(
        isClosed ? Icons.cancel_outlined : Icons.check_circle_outline,
        color: isClosed ? Colors.red : Colors.green,
        size: 24,
      ),
    );
  }

  Widget _buildRecordButton(
    String title,
    String assetPath,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: bgColor.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 18,
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
