import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadPostScreen extends StatefulWidget {
  const UploadPostScreen({super.key});

  @override
  State<UploadPostScreen> createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  File? _selectedImage;
  // Placeholder for file and audio

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isExpanded = false;
        _animationController.reverse();
      });
    }
  }

  void _pickDocument() {
    // Placeholder for document picking logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document picker not implemented')),
    );
    setState(() {
      _isExpanded = false;
      _animationController.reverse();
    });
  }

  void _pickAudio() {
    // Placeholder for audio picking logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audio picker not implemented')),
    );
    setState(() {
      _isExpanded = false;
      _animationController.reverse();
    });
  }

  void _removeAttachment() {
    setState(() {
      _selectedImage = null;
    });
  }

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
            border: Border.all(color: const Color(0xFFA4C639)),
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
          'Upload Post',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Chip
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA4C639).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            DateFormat('MMM d, yyyy').format(DateTime.now()),
                            style: GoogleFonts.inter(
                              color: const Color(0xFFA4C639),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // User Info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.pink, width: 2),
                            ),
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.pink,
                              backgroundImage: AssetImage(
                                'assets/images/logo.png',
                              ), // Placeholder
                              // child: Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mohit',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Gir Gaushala',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description Label
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      // Description Section
                      const SizedBox(height: 8),

                      // Description Input Area
                      Container(
                        height: 400,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          expands: true,
                          maxLines: null,
                          minLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: 'Write description',
                            hintStyle: GoogleFonts.inter(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ),

                      // Display Selected Media
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 16),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: _removeAttachment,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Upload Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle upload logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post Uploaded Successfully!'),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA4C639),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Upload Post',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Floating Action Buttons
          Positioned(
            bottom: 100, // Above the Upload Button
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Column(
                    children: [
                      // Image Button
                      _buildMiniFab(
                        icon: Icons.image,
                        color: Colors.blue,
                        onTap: _pickImage,
                      ),
                      const SizedBox(height: 12),
                      // Document Button
                      _buildMiniFab(
                        icon: Icons.description,
                        color: Colors.indigo,
                        onTap: _pickDocument,
                      ),
                      const SizedBox(height: 12),
                      // Audio Button
                      _buildMiniFab(
                        icon: Icons.graphic_eq,
                        color: Colors.blueAccent,
                        onTap: _pickAudio,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'expand_fab',
                  onPressed: _toggleExpand,
                  backgroundColor: _isExpanded
                      ? const Color(0xFFA4C639).withOpacity(0.8)
                      : const Color(0xFFA4C639),
                  child: Icon(
                    _isExpanded ? Icons.close : Icons.add,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniFab({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: const Color(
          0xFFE8F0FE,
        ), // Light Blue background as per design image
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
