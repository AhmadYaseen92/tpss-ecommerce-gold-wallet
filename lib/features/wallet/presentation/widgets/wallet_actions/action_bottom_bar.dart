import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

class ActionBottomBar extends StatelessWidget {
  final String summaryLabel;
  final String summaryValue;
  final String buttonText;
  final VoidCallback onPressed;

  const ActionBottomBar({
    super.key,
    required this.summaryLabel,
    required this.summaryValue,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surface,
          boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12, offset: Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(summaryLabel, style: TextStyle(color: palette.textSecondary)),
                  Text(
                    summaryValue,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(onPressed: onPressed, child: Text(buttonText)),
            ),
          ],
        ),
      ),
    );
  }
}
