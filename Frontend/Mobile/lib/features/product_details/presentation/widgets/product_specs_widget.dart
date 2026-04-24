import 'package:flutter/material.dart';

class ProductSpecsWidget extends StatelessWidget {
  final String purity;
  final String weight;
  final String materialType;

  const ProductSpecsWidget({super.key, required this.purity, required this.weight, required this.materialType});

  @override
  Widget build(BuildContext context) {
    final showPurity = materialType.trim().toLowerCase() == 'gold' && purity.trim().isNotEmpty;
    return Row(
      children: [
        Expanded(child: _productSpecsCard(context, label: 'Material', value: materialType)),
        const SizedBox(width: 10),
        Expanded(child: _productSpecsCard(context, label: 'Weight', value: weight)),
        if (showPurity) ...[
          const SizedBox(width: 10),
          Expanded(child: _productSpecsCard(context, label: 'Purity', value: purity)),
        ],
      ],
    );
  }

  Widget _productSpecsCard(BuildContext context, {required String label, required String value}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
