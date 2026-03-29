import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/app_cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/app_cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/product_cubit/product_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product/widgets/product_filter_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product/widgets/product_item_widget.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final activeSeller = context.watch<AppCubit>().state.selectedSeller;
    return BlocProvider(
      create: (context) {
        final productCubit = ProductCubit();
        productCubit.loadProducts(seller: activeSeller);
        return productCubit;
      },
      child: DefaultTabController(
        length: 2,
        child: BlocListener<AppCubit, AppState>(
          listenWhen: (previous, current) => previous.selectedSeller != current.selectedSeller,
          listener: (context, state) {
            context.read<ProductCubit>().onGlobalSellerChanged(state.selectedSeller);
          },
          child: Column(
            children: const [
              _ProductPageSellerHeader(),
              TabBar(
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: AppColors.grey,
                indicatorColor: AppColors.primaryColor,
                tabs: [Tab(text: 'Catalog'), Tab(text: 'Market Watch')],
              ),
              Expanded(
                child: TabBarView(
                  children: [_CatalogTab(), _MarketWatchTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductPageSellerHeader extends StatelessWidget {
  const _ProductPageSellerHeader();

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<AppCubit>().state.selectedSeller;
    return Container(
      width: double.infinity,
      color: AppColors.luxuryIvory,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        seller == 'All Sellers' ? 'Showing products from all sellers' : 'Seller scope: $seller',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CatalogTab extends StatelessWidget {
  const _CatalogTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
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
                        cubit: BlocProvider.of<ProductCubit>(context),
                        product: state.products[index],
                      ),
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pushNamed(
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
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _MarketWatchTab extends StatelessWidget {
  const _MarketWatchTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      buildWhen: (_, current) => current is ProductMarketWatchLoaded || current is ProductLoaded,
      builder: (context, state) {
        final cubit = context.read<ProductCubit>();
        final symbols = state is ProductMarketWatchLoaded ? state.symbols : cubit.marketSymbols;

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: symbols.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = symbols[index];
            final isUp = item.change >= 0;
            return Card(
              child: ListTile(
                title: Text(item.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item.name),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      '${isUp ? '+' : ''}${item.change.toStringAsFixed(2)}%',
                      style: TextStyle(color: isUp ? Colors.green : Colors.red),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
