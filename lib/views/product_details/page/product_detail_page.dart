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
          if (state is ProductDetailLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: AppColors.darkGold,
              ),
            );
          } else if (state is ProductDetailLoaded) {
            return Scaffold(
              body: ProductDetailWidget(
                product: product,
                productCubit: BlocProvider.of<ProductCubit>(context),
              ),
            );
          } else if (state is ProductQuantityChanged) {
            return Scaffold(
              body: ProductDetailWidget(
                product: product,
                productCubit: BlocProvider.of<ProductCubit>(context),
              ),
            );
          } else if (state is ProductDetailError) {
            return Scaffold(
              appBar: AppBar(title: const Text("Product Detail")),
              body: Center(child: Text((state).message)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
