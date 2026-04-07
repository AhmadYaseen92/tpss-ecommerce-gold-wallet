import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/market_symbol_entity.dart';

class FilterMarketSymbolsUseCase {
  const FilterMarketSymbolsUseCase();

  List<MarketSymbolEntity> call({
    required List<MarketSymbolEntity> symbols,
    required String seller,
  }) {
    return symbols.where((symbol) => AppReleaseConfig.matchesSeller(seller, symbol.sellerName)).toList();
  }
}
