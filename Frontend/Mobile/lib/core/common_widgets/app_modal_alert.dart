import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

enum AppModalAlertVariant { success, failed, warning, information }

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
        final palette = ctx.appPalette;
        final colors = _variantColors(ctx, variant);

        return AlertDialog(
          backgroundColor: palette.surface,
          surfaceTintColor: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title ?? colors.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textSecondary),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: colors.button,
                foregroundColor: Colors.white,
              ),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  static ({String title, Color button}) _variantColors(
    BuildContext context,
    AppModalAlertVariant variant,
  ) {
    final palette = context.appPalette;
    return switch (variant) {
      AppModalAlertVariant.success => (
          title: 'Success',
          button: const Color(0xFF2E7D32),
        ),
      AppModalAlertVariant.failed => (
          title: 'Error',
          button: const Color(0xFFC62828),
        ),
      AppModalAlertVariant.warning => (
          title: 'Warning',
          button: const Color(0xFFEF6C00),
        ),
      AppModalAlertVariant.information => (
          title: 'Information',
          button: palette.primary,
        ),
    };
  }
}
