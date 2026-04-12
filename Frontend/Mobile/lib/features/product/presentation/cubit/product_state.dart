part of 'product_cubit.dart';

class ProductState {}

final class ProductInitial extends ProductState {}

final class ProductLoading extends ProductState {}

final class ProductLoaded extends ProductState {
  final List<ProductEntity> products;
  final int? categoryId;
  final String seller;

  ProductLoaded({
    required this.products,
    required this.categoryId,
    required this.seller,
  });
}

final class ProductMarketWatchLoaded extends ProductState {
  final List<MarketSymbolEntity> symbols;
  final String seller;

  ProductMarketWatchLoaded({required this.symbols, required this.seller});
}

final class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}

final class ProductDetailLoading extends ProductState {}

final class ProductDetailLoaded extends ProductState {
  final ProductEntity product;

  ProductDetailLoaded(this.product);
}

final class ProductQuantityChanged extends ProductState {
  final int quantity;

  ProductQuantityChanged(this.quantity);
}

final class ProductDetailError extends ProductState {
  final String message;

  ProductDetailError(this.message);
}

final class ProductCartLoaded extends ProductState {
  final List<ProductEntity> cartProducts;

  ProductCartLoaded({required this.cartProducts});
}
