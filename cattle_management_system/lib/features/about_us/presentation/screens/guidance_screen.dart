import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class GuidanceScreen extends StatelessWidget {
  const GuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Guidance',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the Smart Gaushala',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A space of care, compassion, and connection',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            _buildSection('How to Use This App', [
              'This app helps you stay connected with our Gaushala and support cow welfare in meaningful ways.',
            ]),

            _buildSection('Explore & Learn', [
              'Discover our cows and their stories',
              'Learn about daily care, feeding, and wellbeing',
              'Understand the values and traditions of Gaushala seva',
            ]),

            _buildSection('Support with Love', [
              'Contribute to cow care and feeding',
              'Choose seva options that feel right to you',
              'Every small support makes a big difference',
            ]),

            _buildSection('Stay Updated', [
              'View photos and updates from the Gaushala',
              'See how your support is helping',
              'Feel connected, even from afar',
            ]),

            _buildSection('Respect & Responsibility', [
              'This app is built on compassion and respect',
              'Use the platform thoughtfully and kindly',
              'All content is meant to spread awareness and positivity',
            ]),

            const SizedBox(height: 24),
            Text(
              'Let\'s Begin',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join us in caring, serving, and protecting with love.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
