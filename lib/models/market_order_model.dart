enum MarketOrderStatus { pending, filled, rejected, cancelled }

class MarketOrderModel {
  final String id;
  final String symbol;
  final String seller;
  final int quantity;
  final double unitPrice;
  final String paymentMethod;
  final String paymentAccount;
  final MarketOrderStatus status;
  final DateTime createdAt;

  const MarketOrderModel({
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

  double get total => unitPrice * quantity;

  MarketOrderModel copyWith({
    MarketOrderStatus? status,
    double? unitPrice,
    String? paymentMethod,
    String? paymentAccount,
    int? quantity,
  }) {
    return MarketOrderModel(
      id: id,
      symbol: symbol,
      seller: seller,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentAccount: paymentAccount ?? this.paymentAccount,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
