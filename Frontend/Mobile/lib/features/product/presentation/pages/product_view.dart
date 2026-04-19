import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/pages/product_page.dart';

class ProductView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     final palette = context.appPalette;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Shop',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: palette.primary,
          ),
        ),
      ),
      body: ProductPage(),
    );
  }
}