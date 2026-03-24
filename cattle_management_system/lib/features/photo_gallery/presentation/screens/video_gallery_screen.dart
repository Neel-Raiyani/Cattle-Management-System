import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoGalleryScreen extends StatefulWidget {
  const VideoGalleryScreen({super.key});

  @override
  State<VideoGalleryScreen> createState() => _VideoGalleryScreenState();
}

class VideoItem {
  final String id;
  String title;
  String url;
  String description;
  final String coverImage;

  VideoItem({
    required this.id,
    required this.title,
    required this.url,
    required this.description,
    required this.coverImage,
  });
}

class _VideoGalleryScreenState extends State<VideoGalleryScreen> {
  final List<VideoItem> _videos = [
    // Starting with sample data as shown in mockup
    VideoItem(
      id: '1',
      title: 'GIR COW',
      url: 'https://youtu.be/P0BcU4le3hA?si=vT6Vbl1l3xEtR2tO',
      description: 'Indian Gir Cow...',
      coverImage: 'assets/images/cattle_placeholder.png', // Fallback
    ),
  ];

  void _showVideoForm({VideoItem? video}) {
    final isEdit = video != null;
    final titleController = TextEditingController(text: video?.title ?? '');
    final urlController = TextEditingController(text: video?.url ?? '');
    final descController = TextEditingController(
      text: video?.description ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Video' : 'Add Video',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF99AA5A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFieldLabel('Title'),
              const SizedBox(height: 8),
              _buildTextField(titleController, 'Enter video title'),
              const SizedBox(height: 16),
              _buildFieldLabel('URL'),
              const SizedBox(height: 8),
              _buildTextField(
                urlController,
                'YouTube URL',
                suffixIcon: Icons.link,
              ),
              const SizedBox(height: 16),
              _buildFieldLabel('Description'),
              const SizedBox(height: 8),
              _buildTextField(
                descController,
                'Write a description here...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        urlController.text.isNotEmpty) {
                      setState(() {
                        if (isEdit) {
                          video.title = titleController.text;
                          video.url = urlController.text;
                          video.description = descController.text;
                        } else {
                          _videos.add(
                            VideoItem(
                              id: DateTime.now().toString(),
                              title: titleController.text,
                              url: urlController.text,
                              description: descController.text,
                              coverImage:
                                  'assets/images/cattle_placeholder.png',
                            ),
                          );
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF99AA5A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isEdit ? 'Save' : 'Create Video',
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
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    IconData? suffixIcon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF5F6F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, size: 20, color: Colors.black87)
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  void _deleteVideo(int index) {
    setState(() {
      _videos.removeAt(index);
    });
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Video',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this video?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteVideo(index);
            },
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
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
          'Video Gallery',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _videos.isEmpty ? _buildEmptyState() : _buildVideoList(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: () => _showVideoForm(),
          backgroundColor: const Color(0xFF99AA5A),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Add Video',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/no_data_found.png',
            width: 150,
            height: 150,
            color: const Color(0xFF99AA5A).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No data found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF99AA5A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return Container(
          height: 200,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[200],
            image:
                video.coverImage !=
                    'assets/images/cattle_placeholder.png' // Simple check for now
                ? DecorationImage(
                    image: AssetImage(video.coverImage),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Stack(
            children: [
              if (video.coverImage == 'assets/images/cattle_placeholder.png')
                const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.grey,
                    size: 50,
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      video.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      video.description,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showVideoForm(video: video);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(index);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
