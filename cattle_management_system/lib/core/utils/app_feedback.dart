import 'package:flutter/material.dart';

import '../services/app_feedback_service.dart';

class AppFeedback {
  static Future<void> showSuccess(
    BuildContext context,
    String message,
  ) async {
    await AppFeedbackService.showPopup(
      message: message,
      type: AppFeedbackType.success,
    );
  }

  static Future<void> showError(
    BuildContext context,
    String message,
  ) async {
    await AppFeedbackService.showPopup(
      message: message,
      type: AppFeedbackType.error,
    );
  }

  static Future<void> showWarning(
    BuildContext context,
    String message,
  ) async {
    await AppFeedbackService.showPopup(
      message: message,
      type: AppFeedbackType.warning,
    );
  }

  static Future<void> showInfo(
    BuildContext context,
    String message,
  ) async {
    await AppFeedbackService.showPopup(
      message: message,
      type: AppFeedbackType.info,
    );
  }
}
