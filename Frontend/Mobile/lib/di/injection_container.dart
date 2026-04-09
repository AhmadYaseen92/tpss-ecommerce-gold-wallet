import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:tpss_ecommerce_gold_wallet/core/network/dio_factory.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/data/datasources/auth_api_service.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/repositories/auth_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/usecases/login_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/usecases/register_usecase.dart';
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
import 'package:tpss_ecommerce_gold_wallet/features/sell/data/datasources/sell_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/data/repositories/sell_repository_impl.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/repositories/sell_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/usecases/calculate_sell_totals_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/usecases/get_live_sell_price_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/usecases/load_sell_data_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/usecases/submit_sell_order_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/usecases/validate_sell_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/data/datasources/transfer_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/data/repositories/transfer_repository_impl.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/domain/repositories/transfer_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/domain/usecases/calculate_transfer_totals_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/domain/usecases/validate_transfer_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/domain/usecases/verify_transfer_account_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/usecases/load_wallets_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/usecases/watch_wallets_usecase.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/datasources/wallet_action_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/repositories/wallet_action_repository_impl.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/repositories/wallet_action_repository.dart';

class InjectionContainer {
  const InjectionContainer._();

  static final ProductLocalDataSource _productLocalDataSource =
      ProductLocalDataSource();
  static final CartLocalDataSource _cartLocalDataSource = CartLocalDataSource();
  static final WalletLocalDataSource _walletLocalDataSource =
      WalletLocalDataSource();
  static final TransferLocalDataSource _transferLocalDataSource =
      TransferLocalDataSource();
  static final SellLocalDataSource _sellLocalDataSource = SellLocalDataSource();

  static final GetIt sl = GetIt.instance;

  static Future<void> setup() async {
    if (sl.isRegistered<Dio>()) {
      return;
    }

    sl.registerLazySingleton<Dio>(DioFactory.create);
    sl.registerLazySingleton<AuthApiService>(() => AuthApiService(sl<Dio>()));
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(sl<AuthApiService>()),
    );
    sl.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
    );
    sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
    sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl()));
  }

  static LoginUseCase loginUseCase() => sl<LoginUseCase>();
  static RegisterUseCase registerUseCase() => sl<RegisterUseCase>();

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

  static ITransferRepository transferRepository() {
    return TransferRepositoryImpl(_transferLocalDataSource);
  }

  static ValidateTransferUseCase validateTransferUseCase() {
    return ValidateTransferUseCase(transferRepository());
  }

  static VerifyTransferAccountUseCase verifyTransferAccountUseCase() {
    return VerifyTransferAccountUseCase(transferRepository());
  }

  static CalculateTransferTotalsUseCase calculateTransferTotalsUseCase() {
    return const CalculateTransferTotalsUseCase();
  }

  static ISellRepository sellRepository() {
    return SellRepositoryImpl(_sellLocalDataSource);
  }

  static LoadSellDataUseCase loadSellDataUseCase() {
    return LoadSellDataUseCase(sellRepository());
  }

  static GetLiveSellPriceUseCase getLiveSellPriceUseCase() {
    return GetLiveSellPriceUseCase(sellRepository());
  }

  static ValidateSellUseCase validateSellUseCase() {
    return const ValidateSellUseCase();
  }

  static SubmitSellOrderUseCase submitSellOrderUseCase() {
    return SubmitSellOrderUseCase(sellRepository());
  }

  static CalculateSellTotalsUseCase calculateSellTotalsUseCase() {
    return const CalculateSellTotalsUseCase();
  }

  static IWalletRepository walletRepository() {
    return WalletRepositoryImpl(_walletLocalDataSource);
  }

  static LoadWalletsUseCase loadWalletsUseCase() {
    return LoadWalletsUseCase(walletRepository());
  }

  static WatchWalletsUseCase watchWalletsUseCase() {
    return WatchWalletsUseCase(walletRepository());
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
