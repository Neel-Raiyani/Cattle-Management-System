import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'navigation_service.dart';

enum AppFeedbackType { success, error, warning, info }

class AppFeedbackService {
  static bool _isShowing = false;
  static String? _activeKey;

  static Future<void> showPopup({
    required String message,
    String? title,
    AppFeedbackType type = AppFeedbackType.info,
    String? dedupeKey,
    String primaryLabel = 'OK',
    FutureOr<void> Function()? onPrimary,
    bool barrierDismissible = true,
  }) async {
    final navigator = NavigationService.navigatorKey.currentState;
    final context = NavigationService.navigatorKey.currentContext ?? navigator?.context;
    if (context == null || navigator == null || !navigator.mounted) return;

    final resolvedKey = dedupeKey ?? '${type.name}:$message';
    if (_isShowing || _activeKey == resolvedKey) return;

    _isShowing = true;
    _activeKey = resolvedKey;

    try {
      await showGeneralDialog<void>(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierLabel: 'feedback_popup',
        barrierColor: Colors.black.withOpacity(0.32),
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => const SizedBox.shrink(),
        transitionBuilder: (context, animation, _, __) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return Transform.scale(
            scale: Tween<double>(begin: 0.96, end: 1).evaluate(curved),
            child: Opacity(
              opacity: curved.value,
              child: Center(
                child: _FeedbackPopup(
                  title: title ?? _defaultTitle(type),
                  message: message,
                  type: type,
                  primaryLabel: primaryLabel,
                  onPrimary: () async {
                    if (Navigator.of(context, rootNavigator: true).canPop()) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                    if (onPrimary != null) {
                      await onPrimary();
                    }
                  },
                ),
              ),
            ),
          );
        },
      );
    } finally {
      _isShowing = false;
      _activeKey = null;
    }
  }

  static String _defaultTitle(AppFeedbackType type) {
    switch (type) {
      case AppFeedbackType.success:
        return 'Success';
      case AppFeedbackType.error:
        return 'Something went wrong';
      case AppFeedbackType.warning:
        return 'Please check';
      case AppFeedbackType.info:
        return 'Notice';
    }
  }
}

class _FeedbackPopup extends StatelessWidget {
  final String title;
  final String message;
  final AppFeedbackType type;
  final String primaryLabel;
  final VoidCallback onPrimary;

  const _FeedbackPopup({
    required this.title,
    required this.message,
    required this.type,
    required this.primaryLabel,
    required this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _PopupPalette.forType(type);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.soft,
                shape: BoxShape.circle,
              ),
              child: Icon(colors.icon, color: colors.base, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.45,
                color: const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPrimary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.base,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  primaryLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopupPalette {
  final Color base;
  final Color soft;
  final Color shadow;
  final IconData icon;

  const _PopupPalette({
    required this.base,
    required this.soft,
    required this.shadow,
    required this.icon,
  });

  factory _PopupPalette.forType(AppFeedbackType type) {
    switch (type) {
      case AppFeedbackType.success:
        return const _PopupPalette(
          base: Color(0xFF2E7D32),
          soft: Color(0xFFE8F5E9),
          shadow: Color(0x332E7D32),
          icon: Icons.check_rounded,
        );
      case AppFeedbackType.error:
        return const _PopupPalette(
          base: Color(0xFFC62828),
          soft: Color(0xFFFFEBEE),
          shadow: Color(0x33C62828),
          icon: Icons.error_outline_rounded,
        );
      case AppFeedbackType.warning:
        return const _PopupPalette(
          base: Color(0xFFEF6C00),
          soft: Color(0xFFFFF3E0),
          shadow: Color(0x33EF6C00),
          icon: Icons.warning_amber_rounded,
        );
      case AppFeedbackType.info:
        return const _PopupPalette(
          base: Color(0xFF1565C0),
          soft: Color(0xFFE3F2FD),
          shadow: Color(0x331565C0),
          icon: Icons.info_outline_rounded,
        );
    }
  }
}
