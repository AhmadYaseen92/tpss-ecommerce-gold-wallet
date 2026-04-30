import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/product_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/l10n/generated/app_localizations.dart';

class DescriptionWidget extends StatelessWidget {
  final ProductEntity product;

  const DescriptionWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).description, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: palette.textPrimary)),
        const SizedBox(height: 4),
        Text(product.description, style: TextStyle(fontSize: 13, color: palette.textSecondary, height: 1.6)),
      ],
    );
  }
}
