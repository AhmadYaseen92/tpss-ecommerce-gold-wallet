import 'package:flutter/material.dart';

enum AppModalAlertVariant { info, success, failed }

class AppModalAlert {
  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    String buttonText = 'OK',
    AppModalAlertVariant variant = AppModalAlertVariant.info,
  }) async {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (ctx) {
        final colors = switch (variant) {
          AppModalAlertVariant.success => (
            border: const Color(0xFF2E7D32),
            button: const Color(0xFF2E7D32),
            title: 'Success',
          ),
          AppModalAlertVariant.failed => (
            border: const Color(0xFFC62828),
            button: const Color(0xFFC62828),
            title: 'Failed',
          ),
          AppModalAlertVariant.info => (
            border: const Color(0xFF1565C0),
            button: const Color(0xFF1565C0),
            title: 'Notice',
          ),
        };

        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.border, width: 1.4),
          ),
          title: Text(
            title ?? colors.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: colors.button,
              ),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }
}
