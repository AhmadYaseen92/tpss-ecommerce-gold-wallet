import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/market_symbol_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/repositories/product_repository.dart';

class WatchMarketSymbolsUseCase {
  const WatchMarketSymbolsUseCase(this._repository);

  final IProductRepository _repository;

  Stream<List<MarketSymbolEntity>> call() => _repository.watchMarketSymbols();
}
