import 'package:tpss_ecommerce_gold_wallet/features/market_orders/data/datasources/market_order_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/market_orders/domain/entities/market_order_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/market_orders/domain/repositories/market_order_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/models/market_order_model.dart' as legacy_models;

class MarketOrderRepositoryImpl implements MarketOrderRepository {
  MarketOrderRepositoryImpl(this._localDataSource);

  final MarketOrderLocalDataSource _localDataSource;

  @override
  List<MarketOrderEntity> getOrders() {
    return _localDataSource.getOrders().map(_toEntity).toList();
  }

  @override
  void cancelOrder(String orderId) {
    _localDataSource.cancelOrder(orderId);
  }

  @override
  double livePriceForSymbol(String symbol, {double fallback = 0}) {
    return _localDataSource.livePriceForSymbol(symbol, fallback: fallback);
  }

  MarketOrderEntity _toEntity(legacy_models.MarketOrderModel model) {
    return MarketOrderEntity(
      id: model.id,
      symbol: model.symbol,
      seller: model.seller,
      quantity: model.quantity,
      unitPrice: model.unitPrice,
      paymentMethod: model.paymentMethod,
      paymentAccount: model.paymentAccount,
      status: _toDomainStatus(model.status),
      createdAt: model.createdAt,
    );
  }

  MarketOrderStatus _toDomainStatus(legacy_models.MarketOrderStatus status) {
    return switch (status) {
      legacy_models.MarketOrderStatus.pending => MarketOrderStatus.pending,
      legacy_models.MarketOrderStatus.filled => MarketOrderStatus.filled,
      legacy_models.MarketOrderStatus.rejected => MarketOrderStatus.rejected,
      legacy_models.MarketOrderStatus.cancelled => MarketOrderStatus.cancelled,
    };
  }
}
