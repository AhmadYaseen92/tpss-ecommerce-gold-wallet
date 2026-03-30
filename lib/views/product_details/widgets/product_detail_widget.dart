import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/product_cubit/product_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product_details/widgets/authenticity_button_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product_details/widgets/badge_rating_row_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product_details/widgets/bottombar_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product_details/widgets/description_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product_details/widgets/product_image.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product_details/widgets/product_specs_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_modal_alert.dart';

class ProductDetailWidget extends StatelessWidget {
  final ProductItemModel product;
  final ProductCubit productCubit;
  const ProductDetailWidget({
    super.key,
    required this.product,
    required this.productCubit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductImage(
                  imageUrl: product.imageUrl,
                  color: AppColors.darkGold,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BadgeRatingRow(
                        colorText: AppColors.darkGold,
                        textMuted: AppColors.darkGrey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (AppReleaseConfig.showSellerUi) ...[
                        Text(
                          'Seller: ${product.sellerName}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.darkGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '\$${(product.price * 2).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.darkGold,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ProductSpecsWidget(
                        purity: product.purity,
                        weight: product.weight,
                        metal: product.metal,
                      ),
                      const SizedBox(height: 12),
                      // AuthenticityButton(
                      //   color: AppColors.darkGold,
                      //   textMuted: AppColors.darkGrey,
                      //   productCubit: productCubit,
                      // ),
                      // const SizedBox(height: 12),
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
            AppModalAlert.show(
              context,
              title: 'Added to Cart',
              message: '${product.name} x${productCubit.quantity} added to cart',
            );
            productCubit.addCart(product);
          },
          onBuyNow: () {
            productCubit.addCart(
              product.copyWith(quantity: productCubit.quantity),
            );
            Navigator.of(context, rootNavigator: true).pushNamed(
              AppRoutes.checkoutRoute,
              arguments: {
                'title': product.name,
                'seller': product.sellerName,
                'amount': product.price * productCubit.quantity,
              },
            );
          },
          productCubit: productCubit,
          quantity: productCubit.quantity,
        ),
      ],
    );
  }
}
