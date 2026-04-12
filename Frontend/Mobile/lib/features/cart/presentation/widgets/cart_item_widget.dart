import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/grams_hint_label.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/entities/cart_item_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/presentation/cubit/cart_cubit.dart';

class CartItemWidget extends StatelessWidget {
  final CartCubit cartCubit;
  final List<CartItemEntity> cartProducts;
  const CartItemWidget({super.key, required this.cartCubit, required this.cartProducts});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: cartProducts.length + 1,
      itemBuilder: (context, index) {
        if (index == cartProducts.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.productRoute),
                icon: Icon(Icons.add_circle_outline, color: palette.primary),
                label: Text('Add more items', style: TextStyle(color: palette.primary)),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              ),
            ),
          );
        }

        final product = cartProducts[index];
        return Card(
          color: palette.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildProductImage(product.imageUrl, palette),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: palette.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      if (AppReleaseConfig.showSellerUi) ...[
                        Text('Seller: ${product.sellerName}', style: TextStyle(fontSize: 12, color: palette.primary)),
                        const SizedBox(height: 4),
                      ],
                      Opacity(
                        opacity: 0.85,
                        child: Text(product.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: palette.textSecondary)),
                      ),
                      GramsHintLabel(
                        grams: GramsConverter.fromWeightText(product.weight),
                        prefix: 'Weight:',
                      ),
                      const SizedBox(height: 8),
                      Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: palette.textPrimary)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 124,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: palette.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              iconSize: 18,
                              padding: const EdgeInsets.all(4),
                              icon: Icon(Icons.remove, color: palette.textSecondary),
                              onPressed: () {
                                if (product.quantity > 1) {
                                  cartCubit.updateProductQuantity(product.id, product.quantity - 1);
                                }
                              },
                            ),
                            Text('${product.quantity}', style: TextStyle(fontWeight: FontWeight.w600, color: palette.textPrimary)),
                            IconButton(
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              iconSize: 18,
                              padding: const EdgeInsets.all(4),
                              icon: Icon(Icons.add, color: palette.textSecondary),
                              onPressed: product.quantity >= product.availableStock
                                  ? null
                                  : () => cartCubit.updateProductQuantity(product.id, product.quantity + 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => cartCubit.removeProduct(product.id),
                        icon: Icon(Icons.delete_outline, size: 18, color: palette.primary),
                        label: Text('Remove', style: TextStyle(fontSize: 12, color: palette.primary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(String imageUrl, dynamic palette) {
    final parsed = Uri.tryParse(imageUrl.trim());
    final validNetwork = parsed != null && (parsed.scheme == 'http' || parsed.scheme == 'https') && parsed.host.isNotEmpty;
    if (!validNetwork) {
      return Container(
        width: 84,
        height: 84,
        color: palette.surfaceMuted,
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported_outlined, color: palette.textSecondary),
      );
    }

    return Image.network(
      imageUrl,
      width: 84,
      height: 84,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 84,
          height: 84,
          color: palette.surfaceMuted,
          alignment: Alignment.center,
          child: Icon(Icons.broken_image_outlined, color: palette.textSecondary),
        );
      },
    );
  }
}
