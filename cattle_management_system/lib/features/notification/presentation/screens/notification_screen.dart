import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data matching the image
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Ear Tag Alert',
        'description':
            '5 cows are pending for ear tagging. Please complete tagging.',
        'icon': Icons.local_offer,
        'color': Colors.grey,
        'bgColor': Colors.grey.shade100,
      },
      {
        'title': 'Adult (First Pregnancy) Alert',
        'description': '2 cows have become adult. Plan for first pregnancy.',
        'icon': Icons.pets, // Cow icon approximation
        'color': const Color(0xFFA4C639), // Approximation of the olive/yellow
        'bgColor': const Color(0xFFF9FBE7), // Light lime
      },
      {
        'title': 'Pregnancy Check',
        'description': '1 cow need to be checked for pregnancy.',
        'icon': Icons.pregnant_woman,
        'color': Colors.green,
        'bgColor': Colors.green.shade50,
      },
      {
        'title': 'Heat Alert',
        'description': '2 cows are in heat. Plan for pregnancy.',
        'icon': Icons.favorite,
        'color': Colors.pink,
        'bgColor': Colors.pink.shade50,
      },
      {
        'title': 'Missing Parity Info Alert',
        'description':
            '4 cows have no parity info entered. Please update records.',
        'icon': Icons.local_offer,
        'color': Colors.grey,
        'bgColor': Colors.grey.shade100,
      },
    ];

    return Scaffold(
      backgroundColor:
          Colors.white, // Image background looks white or very light grey
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFA4C639),
            ), // AppTheme olive border
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFA4C639),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
        title: Text(
          'Notification',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
              border: Border.all(color: Colors.grey.shade100), // Subtle border
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item['bgColor'],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'], color: item['color'], size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['description'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
