import 'package:tpss_ecommerce_gold_wallet/features/market_orders/data/datasources/market_order_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/market_orders/data/repositories/market_order_repository_impl.dart';
import 'package:tpss_ecommerce_gold_wallet/features/market_orders/domain/repositories/market_order_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/datasources/product_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/repositories/product_repository_impl.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/repositories/product_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/usecases/add_product_to_cart_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/usecases/get_product_detail_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/usecases/get_products_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/usecases/toggle_product_favorite_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/usecases/watch_market_symbols_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/datasources/wallet_action_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/repositories/wallet_action_repository_impl.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/repositories/wallet_action_repository.dart';

class InjectionContainer {
  const InjectionContainer._();

  static final ProductLocalDataSource _productLocalDataSource = ProductLocalDataSource();

  static MarketOrderRepository marketOrderRepository() {
    return MarketOrderRepositoryImpl(MarketOrderLocalDataSource());
  }

  static WalletActionRepository walletActionRepository() {
    return WalletActionRepositoryImpl(WalletActionRemoteDataSource());
  }

  static ProductRepository productRepository() {
    return ProductRepositoryImpl(_productLocalDataSource);
  }

  static GetProductsUseCase getProductsUseCase() {
    return GetProductsUseCase(productRepository());
  }

  static GetProductDetailUseCase getProductDetailUseCase() {
    return GetProductDetailUseCase(productRepository());
  }

  static ToggleProductFavoriteUseCase toggleProductFavoriteUseCase() {
    return ToggleProductFavoriteUseCase(productRepository());
  }

  static AddProductToCartUseCase addProductToCartUseCase() {
    return AddProductToCartUseCase(productRepository());
  }

  static WatchMarketSymbolsUseCase watchMarketSymbolsUseCase() {
    return WatchMarketSymbolsUseCase(productRepository());
  }
}
