import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

class ProductSpecsWidget extends StatelessWidget {
  final String purity;
  final String weight;
  final String metal;

  const ProductSpecsWidget({super.key, required this.purity, required this.weight, required this.metal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _productSpecsCard(context, label: 'Purity', value: purity),
        const SizedBox(width: 10),
        _productSpecsCard(context, label: 'Weight', value: weight),
        const SizedBox(width: 10),
        _productSpecsCard(context, label: 'Metal', value: metal),
      ],
    );
  }

  Widget _productSpecsCard(BuildContext context, {required String label, required String value}) {
    final palette = context.appPalette;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 15, color: palette.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 15, color: palette.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
