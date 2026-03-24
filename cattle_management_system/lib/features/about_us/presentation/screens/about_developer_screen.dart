import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
        title: Text(
          'About Developer',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Center(
              child: Image.asset(
                'assets/icons/empyreal_logo.png',
                height: 60, // approximate height
                errorBuilder: (context, error, stackTrace) => const Text(
                  'Empyreal Infotech',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // About Text
            Text(
              'About The Developer',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'With a strong foundation in modern software development, Empyreal Infotech specializes in building scalable, secure, and user-friendly digital solutions. We focus on creating feature-rich applications that combine strong functionality with clean, intuitive design.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'From idea validation to design, development, testing, and deployment, every project is handled with precision, innovation, and a commitment to quality. Our goal is to deliver reliable technology that helps businesses grow and operate efficiently.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Contact Us
            Text(
              'Contact Us',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _buildContactRow(Icons.phone, '+91-87804-53299'),
            const SizedBox(height: 16),
            _buildContactRow(Icons.email, 'info@empyrealinfotech.com'),
            const SizedBox(height: 16),
            _buildContactRow(Icons.language, 'https://smartgaushala.in'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FBE7), // Light lime/cream background
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
