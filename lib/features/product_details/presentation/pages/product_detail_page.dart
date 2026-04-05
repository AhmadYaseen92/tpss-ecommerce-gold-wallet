import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/models/product_item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/cubit/product_cubit.dart';
import '../widgets/product_detail_widget.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductItemModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ProductCubit();
        cubit.loadProductDetail(product.id);
        return cubit;
      },
      child: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          final palette = context.appPalette;
          final cubit = BlocProvider.of<ProductCubit>(context);
          final isFavorite = state is ProductDetailLoaded ? state.product.isFavorite : product.isFavorite;

          PreferredSizeWidget appBar() => AppBar(
                centerTitle: true,
                title: Text('Product Detail', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: palette.primary)),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                actions: state is ProductDetailLoaded || state is ProductQuantityChanged
                    ? [
                        IconButton(
                          onPressed: () => cubit.toggleDetailFavorite(product.id),
                          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: palette.primary),
                        ),
                      ]
                    : null,
              );

          if (state is ProductDetailLoading) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: appBar(),
              body: const Center(child: CircularProgressIndicator.adaptive(backgroundColor: AppColors.darkGold)),
            );
          }

          if (state is ProductDetailLoaded || state is ProductQuantityChanged) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: appBar(),
              body: ProductDetailWidget(product: product, productCubit: cubit),
            );
          }

          if (state is ProductDetailError) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: appBar(),
              body: Center(child: Text(state.message)),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
