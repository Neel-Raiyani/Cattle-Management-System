import 'package:flutter/material.dart';

import 'media_gallery_screen.dart';

class PhotoGalleryScreen extends StatelessWidget {
  const PhotoGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaGalleryScreen(
      mediaType: 'PHOTO',
      title: 'Photo Gallery',
    );
  }
}
