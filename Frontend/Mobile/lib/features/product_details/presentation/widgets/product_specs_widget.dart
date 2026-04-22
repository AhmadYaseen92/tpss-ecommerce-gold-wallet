import 'package:flutter/material.dart';

class ProductSpecsWidget extends StatelessWidget {
  final String purity;
  final String weight;
  final String materialType;

  const ProductSpecsWidget({super.key, required this.purity, required this.weight, required this.materialType});

  @override
  Widget build(BuildContext context) {
    final specs = <Widget>[
      _productSpecsCard(context, label: 'Material', value: materialType),
      _productSpecsCard(context, label: 'Weight', value: weight),
    ];

    if (materialType.toLowerCase() != 'diamond' && purity.trim().isNotEmpty) {
      specs.add(_productSpecsCard(context, label: 'Purity', value: purity));
    }

    return Wrap(spacing: 10, runSpacing: 10, children: specs);
  }

  Widget _productSpecsCard(BuildContext context, {required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
