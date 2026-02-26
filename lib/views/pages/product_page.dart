import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/views/widgets/product_item_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/widgets/product_filter_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/product_cubit/product_cubit.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        ProductCubit productCubit = ProductCubit();
        productCubit.loadProducts();
        return productCubit;
      },
      child: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductInitial || state is ProductLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: AppColors.darkGold,
              ),
            );
          } else if (state is ProductLoaded) {
            return Column(
              children: [
                ProductFilterBar(
                  productCubit: BlocProvider.of<ProductCubit>(context),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: ProductItemWidget(
                          productCubit: BlocProvider.of<ProductCubit>(context),
                          product: state.products[index],
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.productDetailsRoute,
                            arguments: state.products[index],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is ProductError) {
            return Scaffold(
              appBar: AppBar(title: const Text("Products")),
              body: Center(child: Text((state).message)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
