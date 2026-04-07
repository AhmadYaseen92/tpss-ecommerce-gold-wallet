import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

class GramsConverter {
  static const double ounceInGrams = 28.3495231;

  static double fromSymbol(String symbol) {
    final upper = symbol.toUpperCase();
    if (upper.contains('1KG')) return 1000;
    if (upper.contains('100G')) return 100;
    if (upper.contains('10G')) return 10;
    if (upper.contains('1OZ')) return ounceInGrams;
    return 1;
  }

  static double fromWeightText(String weight) {
    final lower = weight.trim().toLowerCase();
    final value = double.tryParse(lower.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (value == null) return 0;

    if (lower.contains('kg')) return value * 1000;
    if (lower.contains('oz')) return value * ounceInGrams;
    if (lower.contains('g')) return value;
    return value;
  }
}

class GramsHintLabel extends StatelessWidget {
  const GramsHintLabel({
    super.key,
    required this.grams,
    this.prefix = '≈',
  });

  final double grams;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$prefix ${grams.toStringAsFixed(2)} g',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: context.appPalette.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
