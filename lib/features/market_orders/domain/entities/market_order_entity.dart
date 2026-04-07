enum MarketOrderStatus { pending, filled, rejected, cancelled }

enum MarketOrderStatusFilter { all, pending, filled, rejected, cancelled }

class MarketOrderEntity {
  const MarketOrderEntity({
    required this.id,
    required this.symbol,
    required this.seller,
    required this.quantity,
    required this.unitPrice,
    required this.paymentMethod,
    required this.paymentAccount,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String symbol;
  final String seller;
  final int quantity;
  final double unitPrice;
  final String paymentMethod;
  final String paymentAccount;
  final MarketOrderStatus status;
  final DateTime createdAt;

  double get total => unitPrice * quantity;
}
