import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/cattle.dart';

class CowParentDetailsScreen extends StatelessWidget {
  final Cattle cattle;
  final bool isFather;

  const CowParentDetailsScreen({
    super.key,
    required this.cattle,
    required this.isFather,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        title: Text(
          isFather ? 'Father Details' : 'Mother Details',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFather ? Icons.male : Icons.female,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '${isFather ? "Father" : "Mother"} details not available',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
            ),
            // Todo: Implement detailed view when data is available
          ],
        ),
      ),
    );
  }
}
