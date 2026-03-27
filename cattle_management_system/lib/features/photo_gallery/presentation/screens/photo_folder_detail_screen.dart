import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/app_feedback.dart';

class PhotoFolderDetailScreen extends StatefulWidget {
  final String folderId;
  final String folderName;
  final String mediaType;

  const PhotoFolderDetailScreen({
    super.key,
    required this.folderId,
    required this.folderName,
    required this.mediaType,
  });

  @override
  State<PhotoFolderDetailScreen> createState() =>
      _PhotoFolderDetailScreenState();
}

class _PhotoFolderDetailScreenState extends State<PhotoFolderDetailScreen> {
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isUploading = false;
  String? _error;
  List<Map<String, dynamic>> _items = const [];

  bool get _isPhotoFolder => widget.mediaType == 'PHOTO';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await sl<ApiService>().getGalleryItems(
        folderId: widget.folderId,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _readableError(e, fallback: 'Failed to load media items.');
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUpload() async {
    try {
      final XFile? picked = _isPhotoFolder
          ? await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85)
          : await _picker.pickVideo(source: ImageSource.gallery);
      if (picked == null) return;

      final file = File(picked.path);
      final originalName = picked.name.isNotEmpty
          ? picked.name
          : file.uri.pathSegments.last;
      final mimeType = _resolveMimeType(originalName, _isPhotoFolder);
      final size = await file.length();

      setState(() => _isUploading = true);

      final session = await sl<ApiService>().getGalleryUploadSession(
        fileName: originalName,
        fileType: mimeType,
      );
      final uploadUrl = session['uploadUrl']?.toString();
      final key = session['key']?.toString();

      if (uploadUrl == null || uploadUrl.isEmpty || key == null || key.isEmpty) {
        throw ServerException('Upload session is incomplete.', 500);
      }

      final bytes = await file.readAsBytes();
      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': mimeType},
        body: bytes,
      );

      if (uploadResponse.statusCode != 200 &&
          uploadResponse.statusCode != 204) {
        throw ServerException(
          'Media upload failed (${uploadResponse.statusCode}).',
          uploadResponse.statusCode,
        );
      }

      await sl<ApiService>().registerGalleryItem(
        folderId: widget.folderId,
        fileName: key,
        originalName: originalName,
        mimeType: mimeType,
        size: size,
      );

      _showSnackBar(
        _isPhotoFolder ? 'Photo uploaded.' : 'Video uploaded.',
      );
      await _loadItems();
    } catch (e) {
      _showSnackBar(_readableError(e, fallback: 'Failed to upload media.'));
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Item',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Remove "${item['originalName']}" from this folder?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await sl<ApiService>().deleteGalleryItem(id: item['id'].toString());
      _showSnackBar('Item deleted.');
      await _loadItems();
    } catch (e) {
      _showSnackBar(_readableError(e, fallback: 'Failed to delete item.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.folderName,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              '${_items.length} item${_items.length == 1 ? '' : 's'}',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadItems,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _pickAndUpload,
        backgroundColor: const Color(0xFF99AA5A),
        icon: _isUploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.add, color: Colors.white),
        label: Text(
          _isUploading
              ? 'Uploading...'
              : _isPhotoFolder
                  ? 'Upload Photo'
                  : 'Upload Video',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 420,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadItems,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 420,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isPhotoFolder
                          ? Icons.add_photo_alternate_outlined
                          : Icons.video_call_outlined,
                      size: 60,
                      color: const Color(0xFF99AA5A),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isPhotoFolder
                          ? 'No photos in this folder.'
                          : 'No videos in this folder.',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isPhotoFolder
                          ? 'Upload your first photo to sync it with the backend.'
                          : 'Upload your first video to sync it with the backend.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _isPhotoFolder ? _buildPhotoGrid() : _buildVideoList();
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final imageUrl = item['viewUrl']?.toString() ?? '';
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: const Color(0xFFF2F2F2)),
              if (imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildBrokenMedia(),
                )
              else
                _buildBrokenMedia(),
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () => _deleteItem(item),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['originalName']?.toString() ?? 'Photo',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final sizeInMb = ((item['size'] ?? 0) as int) / (1024 * 1024);
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          elevation: 0,
          color: const Color(0xFFF8F8F4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.play_circle_outline, color: Colors.red),
            ),
            title: Text(
              item['originalName']?.toString() ?? 'Video',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${item['mimeType']} - ${sizeInMb.toStringAsFixed(2)} MB',
                style: GoogleFonts.inter(color: Colors.black54),
              ),
            ),
            trailing: IconButton(
              onPressed: () => _deleteItem(item),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrokenMedia() {
    return const Center(
      child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 34),
    );
  }

  String _resolveMimeType(String fileName, bool isPhoto) {
    final extension = fileName.split('.').last.toLowerCase();
    const imageTypes = <String, String>{
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'gif': 'image/gif',
    };
    const videoTypes = <String, String>{
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'm4v': 'video/x-m4v',
      'avi': 'video/x-msvideo',
      'mkv': 'video/x-matroska',
      'webm': 'video/webm',
    };
    return isPhoto
        ? (imageTypes[extension] ?? 'image/jpeg')
        : (videoTypes[extension] ?? 'video/mp4');
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    AppFeedback.showSuccess(context, message);
  }

  String _readableError(Object error, {required String fallback}) {
    if (error is ServerException) {
      return error.message;
    }
    return fallback;
  }
}
