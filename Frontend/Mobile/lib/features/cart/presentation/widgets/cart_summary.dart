import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/core/services/action_summary_builder.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/domain/entities/checkout_route_args.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/entities/cart_item_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';

class CartSummary extends StatelessWidget {
  final CartSummaryEntity summary;
  final List<String> cartProductIds;
  final Future<void> Function()? onCheckoutCompleted;

  const CartSummary({
    super.key,
    required this.summary,
    required this.cartProductIds,
    this.onCheckoutCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final currency = summary.currency;

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
              Text(ActionSummaryBuilder.formatMoney(summary.subtotal, currency: currency), style: TextStyle(fontWeight: FontWeight.w600, color: palette.textPrimary)),
            ],
          ),
          ...summary.feeBreakdowns.map(
            (line) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Opacity(opacity: 0.9, child: Text(line.feeName, style: TextStyle(color: palette.textSecondary))),
                  Text('${line.isDiscount ? '-' : ''}${ActionSummaryBuilder.formatMoney(line.appliedValue, currency: currency)}', style: TextStyle(fontWeight: FontWeight.w600, color: palette.textPrimary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Opacity(opacity: 0.9, child: Text('Discount', style: TextStyle(color: palette.textSecondary))),
              Text('-${ActionSummaryBuilder.formatMoney(summary.discountAmount, currency: currency)}', style: TextStyle(fontWeight: FontWeight.w600, color: palette.textPrimary)),
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
              Text(ActionSummaryBuilder.formatMoney(summary.total, currency: currency), style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: palette.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: AppButton(
              label: 'Proceed to Checkout',
              onPressed: () async {
                final parsedProductIds = cartProductIds
                    .map(int.tryParse)
                    .whereType<int>()
                    .toList();
                final result = await Navigator.of(context, rootNavigator: true).pushNamed(
                  AppRoutes.checkoutRoute,
                  arguments: CheckoutRouteArgs.cart(
                    productIds: parsedProductIds,
                    summary: summary,
                  ),
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
