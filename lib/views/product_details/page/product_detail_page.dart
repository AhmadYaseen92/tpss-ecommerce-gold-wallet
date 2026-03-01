import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/product_cubit/product_cubit.dart';
import '../widgets/product_detail_widget.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductItemModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        ProductCubit productCubit = ProductCubit();
        productCubit.loadProductDetail(product.id);
        return productCubit;
      },
      child: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          final cubit = BlocProvider.of<ProductCubit>(context);
          final isFavorite = state is ProductDetailLoaded
              ? state.product.isFavorite
              : product.isFavorite;

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              centerTitle: true,
              title: const Text("Product Detail"),
              backgroundColor: AppColors.backgroundColor,
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
              actions: [
                IconButton(
                  onPressed: () => cubit.toggleDetailFavorite(product.id),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.darkGold : AppColors.darkGold,
                  ),
                ),
              ],
            ),
            body: Builder(
              builder: (context) {
                if (state is ProductDetailLoading) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: AppColors.darkGold,
                    ),
                  );
                } else if (state is ProductDetailLoaded) {
                  return ProductDetailWidget(
                    product: product,
                    productCubit: cubit,
                  );
                } else if (state is ProductQuantityChanged) {
                  return ProductDetailWidget(
                    product: product,
                    productCubit: cubit,
                  );
                } else if (state is ProductDetailError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}
