String resolveMimeTypeFromFileName(String fileName) {
  final normalized = fileName.trim().toLowerCase();

  if (normalized.endsWith('.jpg') || normalized.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  if (normalized.endsWith('.png')) {
    return 'image/png';
  }
  if (normalized.endsWith('.webp')) {
    return 'image/webp';
  }
  if (normalized.endsWith('.gif')) {
    return 'image/gif';
  }
  if (normalized.endsWith('.bmp')) {
    return 'image/bmp';
  }
  if (normalized.endsWith('.heic')) {
    return 'image/heic';
  }
  if (normalized.endsWith('.mp4')) {
    return 'video/mp4';
  }
  if (normalized.endsWith('.mov')) {
    return 'video/quicktime';
  }
  if (normalized.endsWith('.avi')) {
    return 'video/x-msvideo';
  }
  if (normalized.endsWith('.mkv')) {
    return 'video/x-matroska';
  }
  if (normalized.endsWith('.pdf')) {
    return 'application/pdf';
  }

  return 'application/octet-stream';
}
