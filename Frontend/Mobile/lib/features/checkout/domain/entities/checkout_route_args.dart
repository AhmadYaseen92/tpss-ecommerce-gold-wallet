import 'package:tpss_ecommerce_gold_wallet/features/checkout/domain/entities/checkout_otp_entities.dart';

enum CheckoutSource { product, cart }

class CheckoutRouteArgs {
  const CheckoutRouteArgs._({
    required this.source,
    this.productId,
    this.quantity,
    this.productIds = const <int>[],
    this.title,
    this.seller,
    this.summary,
  });

  factory CheckoutRouteArgs.product({
    required int productId,
    required int quantity,
    String? title,
    String? seller,
    dynamic summary,
  }) {
    return CheckoutRouteArgs._(
      source: CheckoutSource.product,
      productId: productId,
      quantity: quantity,
      title: title,
      seller: seller,
      summary: summary,
    );
  }

  factory CheckoutRouteArgs.cart({
    required List<int> productIds,
    String? title,
    String? seller,
    dynamic summary,
  }) {
    return CheckoutRouteArgs._(
      source: CheckoutSource.cart,
      productIds: List<int>.unmodifiable(productIds),
      title: title,
      seller: seller,
      summary: summary,
    );
  }

  final CheckoutSource source;
  final int? productId;
  final int? quantity;
  final List<int> productIds;
  final String? title;
  final String? seller;
  final dynamic summary;

  String? validate() {
    switch (source) {
      case CheckoutSource.product:
        if (productId == null) return 'Invalid checkout args: productId is required for product checkout.';
        if (quantity == null || quantity! <= 0) {
          return 'Invalid checkout args: quantity must be greater than 0 for product checkout.';
        }
        return null;
      case CheckoutSource.cart:
        if (productIds.isEmpty) {
          return 'Invalid checkout args: productIds must not be empty for cart checkout.';
        }
        return null;
    }
  }

  CheckoutOtpRequestContextEntity toOtpContext() {
    if (source == CheckoutSource.product) {
      return CheckoutOtpRequestContextEntity(
        source: 'product',
        productId: productId,
        quantity: quantity,
      );
    }

    return CheckoutOtpRequestContextEntity(
      source: 'cart',
      productIds: productIds,
    );
  }
}
