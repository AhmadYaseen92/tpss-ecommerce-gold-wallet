import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/cubit/product_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/widgets/catalog_tab_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/widgets/market_watch_tab_widget.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final activeSeller = context.watch<AppCubit>().state.selectedSeller;
    return BlocProvider(
      create: (context) {
        final productCubit = ProductCubit(
          getProductsUseCase: InjectionContainer.getProductsUseCase(),
          getProductDetailUseCase: InjectionContainer.getProductDetailUseCase(),
          toggleProductFavoriteUseCase: InjectionContainer.toggleProductFavoriteUseCase(),
          addProductToCartUseCase: InjectionContainer.addProductToCartUseCase(),
          watchMarketSymbolsUseCase: InjectionContainer.watchMarketSymbolsUseCase(),
        );
        productCubit.loadProducts(seller: activeSeller);
        return productCubit;
      },
      child: Builder(
        builder: (context) {
          return DefaultTabController(
            length: 2,
            child: Material(
              color: Colors.transparent,
              child: BlocListener<AppCubit, AppState>(
                listenWhen: (previous, current) =>
                    previous.selectedSeller != current.selectedSeller ||
                    previous.checkoutRefreshTick !=
                        current.checkoutRefreshTick,
                listener: (context, state) {
                  context.read<ProductCubit>().loadProducts(
                    seller: state.selectedSeller,
                    categoryId: context.read<ProductCubit>().selectedCategoryId,
                  );
                },
                child: AppReleaseConfig.marketWatchEnabled
                    ? Column(
                        children: [
                          TabBar(
                            labelStyle: Theme.of(context).textTheme.titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                            labelColor: context.appPalette.primary,
                            unselectedLabelColor: context.appPalette.textSecondary,
                            indicatorColor: context.appPalette.primary,
                            tabs: [
                              Tab(text: 'Catalog'),
                              Tab(text: 'Market Watch'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: TabBarView(
                              children: [
                                RefreshIndicator(
                                  onRefresh: () => context
                                      .read<ProductCubit>()
                                      .loadProducts(
                                        seller:
                                            context.read<ProductCubit>().activeSeller,
                                        categoryId: context
                                            .read<ProductCubit>()
                                            .selectedCategoryId,
                                      ),
                                  child: CatalogTabWidget(),
                                ),
                                RefreshIndicator(
                                  onRefresh: () => context
                                      .read<ProductCubit>()
                                      .loadProducts(
                                        seller:
                                            context.read<ProductCubit>().activeSeller,
                                        categoryId: context
                                            .read<ProductCubit>()
                                            .selectedCategoryId,
                                      ),
                                  child: MarketWatchTabWidget(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : RefreshIndicator(
                        onRefresh: () => context.read<ProductCubit>().loadProducts(
                          seller: context.read<ProductCubit>().activeSeller,
                          categoryId: context.read<ProductCubit>().selectedCategoryId,
                        ),
                        child: CatalogTabWidget(),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
