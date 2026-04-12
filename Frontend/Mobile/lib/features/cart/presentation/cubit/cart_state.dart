part of 'cart_cubit.dart';

class CartState {}

final class CartInitial extends CartState {}

final class CartLoading extends CartState {}

final class CartLoaded extends CartState {
  final List<CartItemEntity> cartProducts;
  final CartSummaryEntity summary;
  final String selectedSellerFilter;
  final List<String> availableSellers;
  final int? selectedCategoryId;

  CartLoaded({
    required this.cartProducts,
    required this.summary,
    required this.selectedSellerFilter,
    required this.availableSellers,
    required this.selectedCategoryId,
  });
}

final class CartError extends CartState {
  final String message;

  CartError(this.message);
}
