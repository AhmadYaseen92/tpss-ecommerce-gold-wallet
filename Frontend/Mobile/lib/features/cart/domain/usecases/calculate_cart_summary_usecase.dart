import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/entities/cart_item_entity.dart';

class CalculateCartSummaryUseCase {
  const CalculateCartSummaryUseCase();

  CartSummaryEntity call(List<CartItemEntity> items) {
    final subtotal = items.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity));

    return CartSummaryEntity(
      subtotal: subtotal,
      totalFeesAmount: 0,
      discountAmount: 0,
      total: subtotal,
      currency: 'USD',
      feeBreakdowns: const [],
    );
  }
}
