import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/l10n/generated/app_localizations.dart';

class ProductSpecsWidget extends StatelessWidget {
  final String purity;
  final String weight;
  final String materialType;

  const ProductSpecsWidget({
    super.key,
    required this.purity,
    required this.weight,
    required this.materialType,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedMaterial = materialType.trim().toLowerCase();
    final showPurity = (normalizedMaterial == 'gold' || normalizedMaterial == 'silver') && purity.trim().isNotEmpty;
    return Row(
      children: [
        Expanded(child: _productSpecsCard(context, label: AppLocalizations.of(context).material, value: materialType)),
        const SizedBox(width: 10),
        Expanded(child: _productSpecsCard(context, label: AppLocalizations.of(context).weight, value: weight)),
        if (showPurity) ...[
          const SizedBox(width: 10),
          Expanded(child: _productSpecsCard(context, label: AppLocalizations.of(context).purity, value: purity)),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
