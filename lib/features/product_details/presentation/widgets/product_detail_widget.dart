import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/models/product_item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/cubit/product_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product_details/presentation/widgets/badge_rating_row_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product_details/presentation/widgets/bottombar_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product_details/presentation/widgets/description_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product_details/presentation/widgets/product_image.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product_details/presentation/widgets/product_specs_widget.dart';

class ProductDetailWidget extends StatelessWidget {
  final ProductItemModel product;
  final ProductCubit productCubit;
  const ProductDetailWidget({super.key, required this.product, required this.productCubit});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductImage(imageUrl: product.imageUrl, color: palette.primary),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BadgeRatingRow(colorText: palette.primary, textMuted: palette.textSecondary),
                      const SizedBox(height: 12),
                      Text(product.name, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: palette.textPrimary, height: 1.25)),
                      const SizedBox(height: 6),
                      if (AppReleaseConfig.showSellerUi) ...[
                        Text('Seller: ${product.sellerName}', style: TextStyle(fontSize: 13, color: palette.primary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                      ],
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: palette.primary)),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('\$${(product.price * 2).toStringAsFixed(2)}', style: TextStyle(fontSize: 13, color: palette.primary, decoration: TextDecoration.lineThrough)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ProductSpecsWidget(purity: product.purity, weight: product.weight, metal: product.metal),
                      const SizedBox(height: 12),
                      DescriptionWidget(product: product),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        BottomBar(
          onAddToCart: () {
            AppModalAlert.show(context, title: 'Added to Cart', message: '${product.name} x${productCubit.quantity} added to cart');
            productCubit.addCart(product);
          },
          onBuyNow: () {
            productCubit.addCart(product.copyWith(quantity: productCubit.quantity));
            Navigator.of(context, rootNavigator: true).pushNamed(
              AppRoutes.checkoutRoute,
              arguments: {'title': product.name, 'seller': product.sellerName, 'amount': product.price * productCubit.quantity},
            );
          },
          productCubit: productCubit,
          quantity: productCubit.quantity,
        ),
      ],
    );
  }
}
