import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';

class DescriptionWidget extends StatelessWidget {
  final ProductItemModel product;

  const DescriptionWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: palette.textPrimary)),
        const SizedBox(height: 4),
        Text(product.description, style: TextStyle(fontSize: 13, color: palette.textSecondary, height: 1.6)),
      ],
    );
  }
}
