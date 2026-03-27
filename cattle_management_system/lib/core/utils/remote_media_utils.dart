import 'package:flutter/foundation.dart';

bool isRenderableRemoteUrl(String? value) {
  if (value == null || value.trim().isEmpty) return false;
  final normalized = value.trim().toLowerCase();
  return normalized.startsWith('http://') || normalized.startsWith('https://');
}

String? deriveViewUrlFromUploadUrl(String? uploadUrl) {
  if (!isRenderableRemoteUrl(uploadUrl)) return null;
  try {
    final uri = Uri.parse(uploadUrl!.trim());
    return uri.replace(queryParameters: const <String, String>{}, fragment: '').toString();
  } catch (_) {
    return null;
  }
}

String? firstNonEmptyString(Iterable<dynamic> candidates) {
  for (final candidate in candidates) {
    if (candidate == null) continue;
    final value = candidate.toString().trim();
    if (value.isNotEmpty) return value;
  }
  return null;
}

String? firstRenderableUrl(Iterable<dynamic> candidates, {String? uploadUrl}) {
  for (final candidate in candidates) {
    if (candidate == null) continue;
    final value = candidate.toString().trim();
    if (isRenderableRemoteUrl(value)) return value;
  }
  return deriveViewUrlFromUploadUrl(uploadUrl);
}

Map<String, dynamic> nestedMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

void debugMedia(String message) {
  if (kDebugMode) {
    debugPrint('[MEDIA] $message');
  }
}
