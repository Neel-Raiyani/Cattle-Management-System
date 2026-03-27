import 'package:flutter/material.dart';

import '../utils/remote_media_utils.dart';

class AnimalImageBox extends StatelessWidget {
  final String? imageUrl;
  final String placeholderAsset;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final Color backgroundColor;
  final IconData fallbackIcon;
  final Color fallbackIconColor;

  const AnimalImageBox({
    super.key,
    required this.imageUrl,
    required this.placeholderAsset,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.fit = BoxFit.cover,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.fallbackIcon = Icons.pets,
    this.fallbackIconColor = const Color(0xFFB0B0B0),
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = isRenderableRemoteUrl(imageUrl) ? imageUrl!.trim() : null;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: width,
        height: height,
        color: backgroundColor,
        child: resolvedUrl != null
            ? Image.network(
                resolvedUrl,
                fit: fit,
                errorBuilder: (_, __, ___) => _fallback(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: backgroundColor,
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Image.asset(
      placeholderAsset,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(
          fallbackIcon,
          size: 34,
          color: fallbackIconColor,
        ),
      ),
    );
  }
}
