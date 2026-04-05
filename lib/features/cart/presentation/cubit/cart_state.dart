part of 'cart_cubit.dart';


class CartState {}

final class CartInitial extends CartState {}

final class CartLoading extends CartState {}

final class CartLoaded extends CartState {
  final List<ProductItemModel> cartProducts;

  CartLoaded({required this.cartProducts});
}

final class CartError extends CartState {
  final String message;

  CartError(this.message);
}