import 'package:flutter/material.dart';

Widget summaryRow(
  BuildContext context, {
  required String label,
  required String value,
  bool isBold = false,
  Color? valueColor,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: Colors.grey.shade700,
        ),
      ),
      Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: valueColor ?? Colors.black,
        ),
      ),
    ],
  );
}
