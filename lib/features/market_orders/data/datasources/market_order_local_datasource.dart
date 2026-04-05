import 'package:tpss_ecommerce_gold_wallet/data/market_order_repository.dart' as legacy;
import 'package:tpss_ecommerce_gold_wallet/models/market_order_model.dart' as legacy_models;

class MarketOrderLocalDataSource {
  List<legacy_models.MarketOrderModel> getOrders() {
    return legacy.MarketOrderRepository.orders;
  }

  void cancelOrder(String orderId) {
    legacy.MarketOrderRepository.cancelOrder(orderId);
  }

  double livePriceForSymbol(String symbol, {double fallback = 0}) {
    return legacy.MarketOrderRepository.livePriceForSymbol(symbol, fallback: fallback);
  }
}
