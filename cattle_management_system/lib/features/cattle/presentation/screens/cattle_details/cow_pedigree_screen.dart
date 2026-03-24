import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/cattle.dart';

class CowPedigreeScreen extends StatelessWidget {
  final Cattle cattle;
  final String title;

  const CowPedigreeScreen({
    super.key,
    required this.cattle,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Generation 1 (The Cow itself)
            _buildPedigreeNode(cattle, 'Self', true),

            const SizedBox(height: 32),

            // Connectors
            CustomPaint(
              size: const Size(double.infinity, 40),
              painter: TreeConnectorPainter(),
            ),

            // Generation 2 (Parents)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildParentNode('Father', true)),
                const SizedBox(width: 16),
                Expanded(child: _buildParentNode('Mother', false)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPedigreeNode(
    Cattle? cow,
    String role,
    bool isMale, {
    bool isHighlights = false,
  }) {
    // Determine image provider: Network or Asset
    ImageProvider? imageProvider;
    if (cow?.imageUrl != null && cow!.imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(cow.imageUrl!);
    } else {
      imageProvider = AssetImage(
        isMale ? 'assets/icons/father_cow.png' : 'assets/icons/mother_cow.png',
      );
    }

    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isHighlights
                  ? const Color(0xFFA4C639)
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          cow?.name ?? 'Unknown',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Text(role, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
        if (cow != null)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Text(
              'Tag: ${cow.tagNumber}',
              style: GoogleFonts.inter(fontSize: 9, color: Colors.brown),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildParentNode(String role, bool isMale) {
    // Generate dummy parent data
    final dummyParent = Cattle(
      id: 'dummy_${role.toLowerCase()}',
      tagNumber: '${isMale ? 'M' : 'F'}-${DateTime.now().millisecond}',
      name: '$role Name', // Matches "Mother Name" generic text from image
      breed: cattle.breed,
      gender: isMale ? 'Male' : 'Female',
      dateOfBirth: cattle.dateOfBirth.subtract(const Duration(days: 365 * 3)),
      status: 'Healthy',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      weight: 450,
    );

    return Column(
      children: [
        _buildPedigreeNode(dummyParent, role, isMale, isHighlights: false),

        // Connector to Grandparents
        SizedBox(
          height: 24,
          child: CustomPaint(
            size: Size.infinite,
            painter: TreeConnectorPainter(),
          ),
        ),

        // Grandparents
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildGrandParentNode('GrandFather', true)),
            Expanded(child: _buildGrandParentNode('GrandMother', false)),
          ],
        ),
      ],
    );
  }

  Widget _buildGrandParentNode(String role, bool isMale) {
    final dummyGrandParent = Cattle(
      id: 'dummy_grand_${role.toLowerCase()}',
      tagNumber: 'GP-${DateTime.now().microsecond % 1000}',
      name: isMale ? 'GrandFather' : 'GrandMother',
      breed: cattle.breed,
      gender: isMale ? 'Male' : 'Female',
      dateOfBirth: cattle.dateOfBirth.subtract(const Duration(days: 365 * 6)),
      status: 'Healthy',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Reusing _buildPedigreeNode for consistency and asset logic
    // But overriding size/style if needed inside the method or handled by passed params?
    // Simply adapting _buildPedigreeNode to be generic enough or copying logic.
    // Let's copy logic for explicit control over small Grandparent size

    ImageProvider imageProvider;
    // Assuming no image for grandparents usually, or use default
    imageProvider = AssetImage(
      isMale ? 'assets/icons/father_cow.png' : 'assets/icons/mother_cow.png',
    );

    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Text(
            dummyGrandParent.name,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Text(
          role,
          style: GoogleFonts.inter(fontSize: 9, color: Colors.grey),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class TreeConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    const startY = 0.0;
    final endY = size.height;

    // Draw vertical line from top (Parent)
    canvas.drawLine(Offset(centerX, startY), Offset(centerX, endY / 2), paint);

    // Calculate split points (centers of the two children)
    // Child 1 is at 25% width (center of left Expanded)
    // Child 2 is at 75% width (center of right Expanded)
    final leftX = size.width * 0.25;
    final rightX = size.width * 0.75;

    // Draw horizontal connector
    canvas.drawLine(Offset(leftX, endY / 2), Offset(rightX, endY / 2), paint);

    // Draw vertical lines down to children
    canvas.drawLine(Offset(leftX, endY / 2), Offset(leftX, endY), paint);
    canvas.drawLine(Offset(rightX, endY / 2), Offset(rightX, endY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
