import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

class TermsRow extends StatelessWidget {
  final bool value;
  final void Function(bool?)? onChanged;
  final String prefixText;
  final String highlightedText;
  final String suffixText;
  final String? connectorText;
  final String? secondHighlightedText;

  const TermsRow({
    super.key,
    required this.value,
    required this.onChanged,
    this.prefixText = 'I agree to the ',
    this.highlightedText = 'Terms & Conditions',
    this.suffixText = ' for this transfer. Once confirmed, this action cannot be undone.',
    this.connectorText,
    this.secondHighlightedText,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: palette.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: palette.textSecondary,
                ),
                children: [
                  TextSpan(text: prefixText),
                  TextSpan(
                    text: highlightedText,
                    style: TextStyle(
                      color: palette.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (connectorText != null && secondHighlightedText != null) ...
                    [
                      TextSpan(text: connectorText),
                      TextSpan(
                        text: secondHighlightedText,
                        style: TextStyle(
                          color: palette.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  TextSpan(text: suffixText),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
