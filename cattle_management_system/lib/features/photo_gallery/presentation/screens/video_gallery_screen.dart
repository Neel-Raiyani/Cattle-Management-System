import 'package:flutter/material.dart';

import 'media_gallery_screen.dart';

class VideoGalleryScreen extends StatelessWidget {
  const VideoGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaGalleryScreen(
      mediaType: 'VIDEO',
      title: 'Video Gallery',
    );
  }
}
