import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/domain/entities/product_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/cubit/product_cubit.dart';
import '../widgets/product_detail_widget.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final ProductCubit _productCubit;

  @override
  void initState() {
    super.initState();
    _productCubit = ProductCubit(
      getProductsUseCase: InjectionContainer.getProductsUseCase(),
      getProductDetailUseCase: InjectionContainer.getProductDetailUseCase(),
      toggleProductFavoriteUseCase: InjectionContainer.toggleProductFavoriteUseCase(),
      addProductToCartUseCase: InjectionContainer.addProductToCartUseCase(),
      watchMarketSymbolsUseCase: InjectionContainer.watchMarketSymbolsUseCase(),
    );
    _productCubit.loadProductDetail(widget.product.id);
  }

  @override
  void dispose() {
    _productCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _productCubit,
      child: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          final palette = context.appPalette;
          final cubit = BlocProvider.of<ProductCubit>(context);
          final isFavorite = state is ProductDetailLoaded
              ? state.product.isFavorite
              : widget.product.isFavorite;

          PreferredSizeWidget appBar() => AppBar(
                centerTitle: true,
                title: Text('Product Detail', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: palette.primary)),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                actions: state is ProductDetailLoaded || state is ProductQuantityChanged
                    ? [
                        IconButton(
                          onPressed: () =>
                              cubit.toggleDetailFavorite(widget.product.id),
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
            final loadedProduct = state is ProductDetailLoaded
                ? state.product
                : widget.product;
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: appBar(),
              body: ProductDetailWidget(product: loadedProduct, productCubit: cubit),
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
