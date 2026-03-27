import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

String? cattleImageCacheKey(String? imageUrl) {
  if (imageUrl == null || imageUrl.trim().isEmpty) return null;
  final raw = imageUrl.trim();
  final uri = Uri.tryParse(raw);
  if (uri == null) return raw;

  final normalizedPath = uri.path.trim();
  if (normalizedPath.isEmpty) return raw;
  return normalizedPath.toLowerCase();
}

ImageProvider? cattleNetworkImageProvider(String? imageUrl) {
  if (imageUrl == null || imageUrl.trim().isEmpty) return null;
  final raw = imageUrl.trim();
  return CachedNetworkImageProvider(
    raw,
    cacheKey: cattleImageCacheKey(raw),
  );
}
