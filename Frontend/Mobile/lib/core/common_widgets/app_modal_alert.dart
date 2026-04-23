import 'package:flutter/material.dart';

enum AppModalAlertVariant { success, failed, warning }

class AppModalAlert {
  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    String buttonText = 'OK',
    AppModalAlertVariant variant = AppModalAlertVariant.warning,
  }) async {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isFailed = variant == AppModalAlertVariant.failed;
        final colors = switch (variant) {
          AppModalAlertVariant.success => (
            border: const Color(0xFF2E7D32),
            button: theme.colorScheme.primary,
            titleColor: const Color(0xFF111827),
            title: 'Success',
          ),
          AppModalAlertVariant.failed => (
            border: Colors.transparent,
            button: const Color(0xFFC62828),
            titleColor: const Color(0xFFC62828),
            title: 'Failed',
          ),
          AppModalAlertVariant.warning => (
            border: const Color(0xFFEF6C00),
            button: const Color(0xFFEF6C00),
            titleColor: const Color(0xFF111827),
            title: 'Warning',
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
            style: TextStyle(fontWeight: FontWeight.w700, color: colors.titleColor),
          ),
          content: Text(message, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            isFailed
                ? TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Color(0xFFC62828),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: FilledButton.styleFrom(backgroundColor: colors.button),
                    child: Text(buttonText),
                  ),
          ],
        );
      },
    );
  }
}
