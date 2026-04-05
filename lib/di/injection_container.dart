import 'package:tpss_ecommerce_gold_wallet/features/market_orders/data/datasources/market_order_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/market_orders/data/repositories/market_order_repository_impl.dart';
import 'package:tpss_ecommerce_gold_wallet/features/market_orders/domain/repositories/market_order_repository.dart';

/// Temporary composition root for feature dependencies.
///
/// Extend this class as more features move to constructor-injected
/// repositories/use-cases.
class InjectionContainer {
  const InjectionContainer._();

  static MarketOrderRepository marketOrderRepository() {
    return MarketOrderRepositoryImpl(MarketOrderLocalDataSource());
  }
}
