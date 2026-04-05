import 'package:tpss_ecommerce_gold_wallet/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/repositories/cart_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/add_cart_product_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/remove_cart_product_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/domain/usecases/update_cart_product_quantity_usecase.dart';
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
  static final CartLocalDataSource _cartLocalDataSource = CartLocalDataSource();

  static IMarketOrderRepository marketOrderRepository() {
    return MarketOrderRepositoryImpl(MarketOrderLocalDataSource());
  }

  static IWalletActionRepository walletActionRepository() {
    return WalletActionRepositoryImpl(WalletActionRemoteDataSource());
  }

  static IProductRepository productRepository() {
    return ProductRepositoryImpl(_productLocalDataSource);
  }

  static ICartRepository cartRepository() {
    return CartRepositoryImpl(_cartLocalDataSource);
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

  static GetCartItemsUseCase getCartItemsUseCase() {
    return GetCartItemsUseCase(cartRepository());
  }

  static AddCartProductUseCase addCartProductUseCase() {
    return AddCartProductUseCase(cartRepository());
  }

  static RemoveCartProductUseCase removeCartProductUseCase() {
    return RemoveCartProductUseCase(cartRepository());
  }

  static UpdateCartProductQuantityUseCase updateCartProductQuantityUseCase() {
    return UpdateCartProductQuantityUseCase(cartRepository());
  }
}
