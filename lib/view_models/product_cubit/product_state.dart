part of 'product_cubit.dart';

class ProductState {}

final class ProductInitial extends ProductState {}

final class ProductLoading extends ProductState {}

final class ProductLoaded extends ProductState {
  final List<ProductItemModel> products;
    final String category;

  ProductLoaded({ required this.products,required this.category});
}

final class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}

