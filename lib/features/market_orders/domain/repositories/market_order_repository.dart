import 'package:tpss_ecommerce_gold_wallet/features/market_orders/domain/entities/market_order_entity.dart';

abstract class IMarketOrderRepository {
  List<MarketOrderEntity> getOrders();

  void cancelOrder(String orderId);

  double livePriceForSymbol(String symbol, {double fallback = 0});
}
