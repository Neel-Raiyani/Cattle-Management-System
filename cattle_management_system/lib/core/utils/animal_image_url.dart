String? _firstNonEmpty(Iterable<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return null;
}

bool isHttpImageUrl(String? value) {
  final raw = value?.trim();
  if (raw == null || raw.isEmpty) return false;
  final normalized = raw.toLowerCase();
  return normalized.startsWith('http://') || normalized.startsWith('https://');
}

String? unwrapNestedImageUrl(String? value) {
  final raw = value?.trim();
  if (raw == null || raw.isEmpty) return null;

  final lower = raw.toLowerCase();
  const encodedMarkers = <String>[
    'https%3a%2f%2f',
    'http%3a%2f%2f',
    'https%3a//',
    'http%3a//',
  ];

  var markerIndex = -1;
  for (final marker in encodedMarkers) {
    final index = lower.indexOf(marker);
    if (index != -1 && (markerIndex == -1 || index < markerIndex)) {
      markerIndex = index;
    }
  }

  if (markerIndex != -1) {
    final endIndex = raw.indexOf('?', markerIndex);
    final encodedUrl =
        endIndex == -1 ? raw.substring(markerIndex) : raw.substring(markerIndex, endIndex);
    final decodedUrl = Uri.decodeComponent(encodedUrl).trim();
    if (isHttpImageUrl(decodedUrl)) {
      return decodedUrl;
    }
  }

  final decoded = Uri.decodeFull(raw);
  final matches = RegExp(r'https?://', caseSensitive: false).allMatches(decoded).toList();
  if (matches.length >= 2) {
    final nestedUrl = decoded.substring(matches[1].start).split('?').first.trim();
    if (isHttpImageUrl(nestedUrl)) {
      return nestedUrl;
    }
  }

  return null;
}

bool isWrappedImageUrl(String? value) => unwrapNestedImageUrl(value) != null;

String? normalizeAnimalImageUrl(
  String? primary, {
  List<String?> fallbacks = const [],
}) {
  final candidates = <String?>[primary, ...fallbacks];

  for (final candidate in candidates) {
    final raw = candidate?.trim();
    if (raw == null || raw.isEmpty) continue;
    if (isHttpImageUrl(raw) && !isWrappedImageUrl(raw)) {
      return raw;
    }
  }

  for (final candidate in candidates) {
    final unwrapped = unwrapNestedImageUrl(candidate);
    if (isHttpImageUrl(unwrapped)) {
      return unwrapped;
    }
  }

  return _firstNonEmpty(candidates);
}

String? deriveAnimalImageStorageKey({
  String? key,
  String? uploadUrl,
  String? viewUrl,
}) {
  final directKey = _firstNonEmpty([key]);
  if (directKey != null && !isHttpImageUrl(directKey)) {
    return directKey;
  }

  final source = _firstNonEmpty([
    if (directKey != null) unwrapNestedImageUrl(directKey) ?? directKey,
    unwrapNestedImageUrl(uploadUrl) ?? uploadUrl,
    unwrapNestedImageUrl(viewUrl) ?? viewUrl,
  ]);

  if (source == null) return null;
  if (!isHttpImageUrl(source)) {
    final normalized = source.replaceAll('\\', '/');
    final segment = normalized.split('/').last.trim();
    return segment.isEmpty ? null : segment;
  }

  final uri = Uri.tryParse(source);
  if (uri == null || uri.pathSegments.isEmpty) {
    return null;
  }

  final lastSegment = Uri.decodeComponent(uri.pathSegments.last).trim();
  return lastSegment.isEmpty ? null : lastSegment;
}
