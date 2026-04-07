import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/cubit/product_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/widgets/product_filter_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/widgets/product_item_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/widgets/seller_filter_bar_widget.dart';

class CatalogTabWidget extends StatelessWidget {
  const CatalogTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      buildWhen: (_, current) =>
          current is ProductInitial || current is ProductLoading || current is ProductLoaded || current is ProductError,
      builder: (context, state) {
        if (state is ProductInitial || state is ProductLoading) {
          return const Center(child: CircularProgressIndicator.adaptive(backgroundColor: AppColors.darkGold));
        } else if (state is ProductLoaded || state is ProductMarketWatchLoaded) {
          final products = state is ProductLoaded ? state.products : context.read<ProductCubit>().visibleCatalogProducts;
          return Column(
            children: [
              const SellerFilterBarWidget(),
              ProductFilterBar(productCubit: BlocProvider.of<ProductCubit>(context)),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: ProductItemWidget(cubit: BlocProvider.of<ProductCubit>(context), product: products[index]),
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pushNamed(
                          AppRoutes.productDetailsRoute,
                          arguments: products[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        } else if (state is ProductError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
