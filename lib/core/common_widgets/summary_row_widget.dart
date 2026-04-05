import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

Widget summaryRow(
  BuildContext context, {
  required String label,
  required String value,
  bool isBold = false,
  Color? valueColor,
}) {
  final palette = context.appPalette;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: palette.textSecondary,
        ),
      ),
      Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: valueColor ?? palette.textPrimary,
        ),
      ),
    ],
  );
}
