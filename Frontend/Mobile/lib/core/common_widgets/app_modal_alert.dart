import 'package:flutter/material.dart';

class AppModalAlert {
  static Future<void> show(
    BuildContext context, {
    required String message,
    String title = 'Notice',
    String buttonText = 'OK',
  }) async {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);

        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            title,
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
                backgroundColor: theme.colorScheme.primary,
              ),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }
}
