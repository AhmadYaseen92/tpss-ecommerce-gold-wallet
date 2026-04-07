import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/market_orders/domain/entities/market_order_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/market_orders/domain/repositories/market_order_repository.dart';

class GetFilteredMarketOrders {
  GetFilteredMarketOrders(this._repository);

  final IMarketOrderRepository _repository;

  List<MarketOrderEntity> call({
    required String sellerFilter,
    required MarketOrderStatusFilter statusFilter,
  }) {
    final allOrders = _repository.getOrders();
    return allOrders.where((order) {
      final sellerMatch = AppReleaseConfig.matchesSeller(sellerFilter, order.seller);
      final statusMatch = switch (statusFilter) {
        MarketOrderStatusFilter.all => true,
        MarketOrderStatusFilter.pending => order.status == MarketOrderStatus.pending,
        MarketOrderStatusFilter.filled => order.status == MarketOrderStatus.filled,
        MarketOrderStatusFilter.rejected => order.status == MarketOrderStatus.rejected,
        MarketOrderStatusFilter.cancelled => order.status == MarketOrderStatus.cancelled,
      };
      return sellerMatch && statusMatch;
    }).toList();
  }
}
