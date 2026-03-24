import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class PhotoFolderDetailScreen extends StatefulWidget {
  final String folderName;
  const PhotoFolderDetailScreen({super.key, required this.folderName});

  @override
  State<PhotoFolderDetailScreen> createState() =>
      _PhotoFolderDetailScreenState();
}

class PhotoItem {
  final String id;
  final String? imageUrl;
  final File? imageFile;
  final double height;

  PhotoItem({
    required this.id,
    this.imageUrl,
    this.imageFile,
    required this.height,
  });
}

class _PhotoFolderDetailScreenState extends State<PhotoFolderDetailScreen> {
  final List<PhotoItem> _photos = [];

  void _deletePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  Future<void> _addPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        // Vary heights slightly to achieve the masonry effect from the image
        final double h = _photos.length % 3 == 0
            ? 250
            : (_photos.length % 2 == 0 ? 180 : 220);
        _photos.add(
          PhotoItem(
            id: DateTime.now().toString(),
            imageFile: File(image.path),
            height: h,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          widget.folderName,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column (Width ~169 based on standard screen padding)
            Expanded(child: Column(children: _buildColumnItems(0))),
            const SizedBox(width: 12),
            // Right Column
            Expanded(child: Column(children: _buildColumnItems(1))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPhoto,
        backgroundColor: const Color(0xFF99AA5A),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  List<Widget> _buildColumnItems(int columnIndex) {
    List<Widget> items = [];
    for (int i = 0; i < _photos.length; i++) {
      if (i % 2 == columnIndex) {
        items.add(_buildPhotoCard(_photos[i], i));
        items.add(const SizedBox(height: 12));
      }
    }
    return items;
  }

  Widget _buildPhotoCard(PhotoItem photo, int index) {
    return Stack(
      children: [
        // Image Container with exact sizing logic
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: photo.imageFile != null
              ? Image.file(
                  photo.imageFile!,
                  height: photo.height,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: photo.height,
                  width: double.infinity,
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
        ),
        // Precise Cross Button from Image
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () => _deletePhoto(index),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF99AA5A,
                ), // Matching the olive green FAB/theme
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
