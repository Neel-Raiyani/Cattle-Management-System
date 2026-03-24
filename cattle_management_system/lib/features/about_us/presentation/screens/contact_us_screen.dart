import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Contact Us',
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
            // Header Image/Brand
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/cowlogo_splash.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Smart Gaushala',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Contact Methods
            _buildContactMethod(
              icon: Icons.chat_bubble_outline,
              color: Colors.green,
              title: 'Contact Us Via Whatsapp',
              subtitle: 'Response within 1 business day',
              bgColor: Color(0xFFF1F8E9),
            ),
            const SizedBox(height: 16),
            _buildContactMethod(
              icon: Icons.phone,
              color: AppTheme.primaryColor,
              title: 'Contact Us Via Call',
              subtitle: 'Response within 1 business day',
              bgColor: Color(0xFFF9FBE7), // Light lime
            ),
            const SizedBox(height: 16),
            _buildContactMethod(
              icon: Icons.email_outlined,
              color: AppTheme.primaryColor,
              title: 'Contact Us Via Email',
              subtitle: 'Response within 1 business day',
              bgColor: Color(0xFFF9FBE7),
            ),

            const SizedBox(height: 32),
            Text(
              'Reach Us Via',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Social Media
            _buildSocialCard(
              icon: Icons.camera_alt, // Placeholder for Insta
              color: Colors.pink,
              title: 'Instagram',
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.orange],
              ), // Insta gradient simulation
            ),
            const SizedBox(height: 16),
            _buildSocialCard(
              icon: Icons.facebook,
              color: Colors.blue,
              title: 'Facebook',
            ),
            const SizedBox(height: 16),
            _buildSocialCard(
              icon: Icons
                  .smart_display, // Use smart_display for YouTube-like icon if play_arrow is too simple
              color: Colors.red,
              title: 'Youtube',
            ),

            const SizedBox(height: 40),

            // Submit Button (Based on design image showing it)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Submit', // Or maybe "Contact Support" if functionality implied? Sticking to design label.
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Color bgColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFFA4C639),
                ), // Light olive text
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialCard({
    required IconData icon,
    required Color color,
    required String title,
    Gradient? gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // Using gradient for Insta, solid color for others if no gradient
              gradient: gradient,
              color: gradient == null ? color : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
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
    );
  }
}
