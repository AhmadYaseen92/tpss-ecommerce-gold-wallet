import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/cubit/product_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/widgets/app_button.dart';

class BottomBar extends StatelessWidget {
  final int quantity;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final ProductCubit productCubit;

  const BottomBar({super.key, required this.quantity, required this.onAddToCart, required this.onBuyNow, required this.productCubit});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border, width: 1)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 20, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quantity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: palette.textPrimary)),
                Container(
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: palette.border),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove), color: palette.textPrimary, onPressed: productCubit.decreaseQuantity),
                      SizedBox(width: 32, child: Text('$quantity', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: palette.textPrimary))),
                      IconButton(icon: const Icon(Icons.add), color: palette.textPrimary, onPressed: productCubit.increaseQuantity),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onAddToCart,
                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.textPrimary,
                      side: BorderSide(color: palette.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: SizedBox(height: 48, child: AppButton(label: 'Buy Now', cubit: productCubit, onPressed: onBuyNow))),
            ],
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
