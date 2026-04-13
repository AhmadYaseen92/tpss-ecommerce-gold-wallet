import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/entities/cart_item_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';

class CartSummary extends StatelessWidget {
  final CartSummaryEntity summary;
  final List<String> cartProductIds;
  final String? selectedSellerName;
  final Future<void> Function()? onCheckoutCompleted;

  const CartSummary({
    super.key,
    required this.summary,
    required this.cartProductIds,
    this.selectedSellerName,
    this.onCheckoutCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: const [BoxShadow(color: AppColors.black12, blurRadius: 8)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Opacity(opacity: 0.9, child: Text('Subtotal', style: TextStyle(color: palette.textSecondary))),
              Text('\$${summary.subtotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w600, color: palette.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Opacity(opacity: 0.9, child: Text('Tax (5.0%)', style: TextStyle(color: palette.textSecondary))),
              Text('\$${summary.tax.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w600, color: palette.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Opacity(opacity: 0.9, child: Text('Fee', style: TextStyle(color: palette.textSecondary))),
                  const SizedBox(width: 6),
                  Icon(Icons.info_outline, size: 16, color: palette.textSecondary),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.greenShade50, borderRadius: BorderRadius.circular(8)),
                child: const Text('FREE', style: TextStyle(color: AppColors.green)),
              ),
            ],
          ),
          Divider(height: 20, color: palette.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(opacity: 0.9, child: Text('Total Amount', style: TextStyle(color: palette.textSecondary))),
                  Opacity(opacity: 0.75, child: Text('Includes all duties', style: TextStyle(fontSize: 12, color: palette.textSecondary))),
                ],
              ),
              Text('\$${summary.total.toStringAsFixed(2)}', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: palette.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: AppButton(
              label: 'Proceed to Checkout',
              onPressed: () async {
                final result = await Navigator.of(context, rootNavigator: true).pushNamed(
                  AppRoutes.checkoutRoute,
                  arguments: {
                    'source': 'cart',
                    'fromCart': true,
                    'productIds': cartProductIds,
                    'amount': summary.total,
                    'seller': selectedSellerName,
                  },
                );
                if (result == true) {
                  await onCheckoutCompleted?.call();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
