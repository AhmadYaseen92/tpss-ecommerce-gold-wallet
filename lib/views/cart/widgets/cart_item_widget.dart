import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/cart_cubit/cart_cubit.dart';

class CartItemWidget extends StatelessWidget {
  final CartCubit cartCubit;
  final List<ProductItemModel> cartProducts;
  const CartItemWidget({
    super.key,
    required this.cartCubit,
    required this.cartProducts,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: cartProducts.length + 1,
      itemBuilder: (context, index) {
        if (index == cartProducts.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                   Navigator.pushNamed(
                            context,
                            AppRoutes.productRoute,
                          );
                },
                icon: Icon(Icons.add_circle_outline, color: AppColors.darkGold),
                label: Text(
                  'Add more items',
                  style: TextStyle(color: AppColors.darkGold),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          );
        }
        final product = cartProducts[index];
        return Card(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    product.imageUrl,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (AppReleaseConfig.showSellerUi) ...[
                        Text(
                          'Seller: ${product.sellerName}',
                          style: const TextStyle(fontSize: 12, color: AppColors.darkGold),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Opacity(
                        opacity: 0.7,
                        child: Text(
                          product.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.greyShade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (product.quantity > 1) {
                                cartCubit.updateProductQuantity(
                                  product.id,
                                  product.quantity - 1,
                                );
                              }
                            },
                          ),
                          Text(
                            '${product.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              final newQty = product.quantity + 1;
                              cartCubit.updateProductQuantity(
                                product.id,
                                newQty,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => cartCubit.removeProduct(product.id),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.darkGold,
                      ),
                      label: Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
