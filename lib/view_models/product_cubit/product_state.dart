part of 'product_cubit.dart';

class ProductState {}

final class ProductInitial extends ProductState {}

final class ProductLoading extends ProductState {}

final class ProductLoaded extends ProductState {
  final List<ProductItemModel> products;

  ProductLoaded(this.products);
}

final class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}

final class ProductFiltered extends ProductState {
  final List<ProductItemModel> filteredProducts;
  final String category;

  ProductFiltered({required this.filteredProducts,required this.category});
}
