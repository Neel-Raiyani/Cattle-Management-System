import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../features/milk_production/presentation/screens/milk_production_screen.dart';
import '../../../milk_distribution/presentation/screens/distribute_milk_screen.dart';

class GaushalaTab extends StatelessWidget {
  const GaushalaTab({super.key});

  final Color _oliveGreen = const Color(0xFF8DA94D); // Adjusted to image

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'All Cow',
                  '08',
                  'assets/icons/all_cow_icon.png',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'All Bull',
                  '10',
                  'assets/icons/all_bull_icon.png',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Cattle Status
          _buildSectionHeader('Cattle Status', action: 'See All'),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildStatusCircle('03', 'Lactating', Colors.green),
                _buildStatusCircle('03', 'Heifer', Colors.teal),
                _buildStatusCircle('03', 'Calving', Colors.orange),
                _buildStatusCircle('03', 'Dry', Colors.brown),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today's Production
          // Today's Production
          Container(
            decoration: BoxDecoration(
              color: _oliveGreen,
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: AssetImage(
                  'assets/images/pattern_bg.png',
                ), // Subtle pattern
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MilkProductionScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.water_drop,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Today\'s Production',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '52.0',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: 'Ltr',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildProductionSubCard(
                              'Morning',
                              '26.0 Ltr',
                              Icons.wb_sunny_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildProductionSubCard(
                              'Evening',
                              '26.0 Ltr',
                              Icons.nightlight_round,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Health & Reproduction
          _buildSectionHeader('Health & Reproduction'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildListRow(
                  Icons.favorite,
                  Colors.pink,
                  'Heat Record',
                  'Total Active',
                  '-',
                ),
                const Divider(height: 24),
                _buildListRow(
                  Icons.pregnant_woman,
                  Colors.purple,
                  'Conception',
                  'Pregnancy Status',
                  '-',
                ),
                const Divider(height: 24),
                _buildListRow(
                  Icons.block,
                  Colors.grey,
                  'Dry Off Cow',
                  'Target Date',
                  '-',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Distribute Milk
          // Distribute Milk
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9), // Light Green bg
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DistributeMilkScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distribute Milk',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Track daily delivery',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Reports & Alerts Grid
          Row(
            children: [
              Expanded(
                child: _buildGridCard(
                  Icons.article,
                  Colors.blue,
                  'Reports',
                  'View Analytics',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGridCard(
                  Icons.notifications_active,
                  Colors.red,
                  'Alerts',
                  'View Alerts',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Animals Left
          _buildSectionHeader('Animal Left from Gaushala'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildListRow(Icons.home_work, Colors.orange, 'Sell', '', '-'),
                const Divider(),
                _buildListRow(
                  Icons.warning,
                  Colors.grey,
                  'Death',
                  '',
                  '-',
                ), // skull isn't in material icons? Use warning
                const Divider(),
                _buildListRow(
                  Icons.volunteer_activism,
                  Colors.green,
                  'Donation',
                  '',
                  '-',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Animal Health Information
          _buildSectionHeader('Animal Health Information'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHealthCard(
                  'Medical',
                  Icons.medical_services_outlined,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHealthCard(
                  'Vaccination',
                  Icons.colorize_outlined,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHealthCard(
                  'Deworming',
                  Icons.spa_outlined,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHealthCard(
                  'Lab Testing',
                  Icons.biotech_outlined,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sick Animal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE), // Light Red
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sick_outlined,
                    color: Colors.brown,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sick Animal',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        '0',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
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
          const SizedBox(height: 24),

          // Gallery
          Row(
            children: [
              Expanded(
                child: _buildHealthCard(
                  'Photo Gallery',
                  Icons.image_outlined,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHealthCard(
                  'Video Gallery',
                  Icons.movie_outlined,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (action != null)
          Text(
            action,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8DA94D),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String count, String asset) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.arrow_drop_down, color: _oliveGreen),
                  Text(
                    title,
                    style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Text(
                count,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _oliveGreen,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(asset, width: 40, height: 40), // Use parameter
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCircle(String count, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 12,
        bottom: 8,
      ), // Add bottom padding for shadow
      child: Container(
        width: 100, // Fixed width for card look
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFA5D6A7),
                  width: 2,
                ), // Light Green Border
              ),
              child: Text(
                count,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF388E3C), // Dark Green Text
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductionSubCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 10),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(
    IconData icon,
    Color color,
    String title,
    String subtitle,
    String value, {
    String? assetPath,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: assetPath != null
              ? Image.asset(assetPath, width: 20, height: 20, color: color)
              : Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildGridCard(
    IconData icon,
    Color color,
    String title,
    String subtitle, {
    String? assetPath,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: assetPath != null
                ? Image.asset(assetPath, width: 20, height: 20, color: color)
                : Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
              ),
              const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard(
    String title,
    IconData icon,
    Color color, {
    String? assetPath,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: assetPath != null
                ? Image.asset(assetPath, width: 20, height: 20, color: color)
                : Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14, // Adjusted size to fit
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
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
    );
  }
}
