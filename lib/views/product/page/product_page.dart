import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/models/market_symbol_model.dart';
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
              TabBar(
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: AppColors.grey,
                indicatorColor: AppColors.primaryColor,
                tabs: [Tab(text: 'Catalog'), Tab(text: 'Market Watch')],
              ),
              Expanded(child: TabBarView(children: [_CatalogTab(), _MarketWatchTab()])),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerFilterBar extends StatelessWidget {
  const _SellerFilterBar();

  @override
  Widget build(BuildContext context) {
    final selectedSeller = context.watch<AppCubit>().state.selectedSeller;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: AppCubit.supportedSellers.map((seller) {
            final isSelected = seller == selectedSeller;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(seller),
                selected: isSelected,
                onSelected: (_) => context.read<AppCubit>().setSeller(seller),
                selectedColor: AppColors.luxuryIvory,
                side: BorderSide(color: isSelected ? AppColors.primaryColor : AppColors.greyBorder),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CatalogTab extends StatelessWidget {
  const _CatalogTab();

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
              const _SellerFilterBar(),
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

class _MarketWatchTab extends StatelessWidget {
  const _MarketWatchTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      buildWhen: (_, current) => current is ProductMarketWatchLoaded || current is ProductLoaded,
      builder: (context, state) {
        final cubit = context.read<ProductCubit>();
        final symbols = state is ProductMarketWatchLoaded ? state.symbols : cubit.visibleMarketSymbols;

        return Column(
          children: [
            const _SellerFilterBar(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: symbols.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = symbols[index];
                  final isUp = item.change >= 0;
                  return Card(
                    child: ListTile(
                      onTap: () => _openMarketDetail(context, item),
                      title: Text(item.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item.name} • ${item.sellerName}'),
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
              ),
            ),
          ],
        );
      },
    );
  }

  void _openMarketDetail(BuildContext context, MarketSymbolModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isUp = item.change >= 0;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.symbol, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${item.name} • Seller: ${item.sellerName}'),
              const SizedBox(height: 12),
              Text('Live Price: \$${item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
              Text(
                '24h: ${isUp ? '+' : ''}${item.change.toStringAsFixed(2)}%',
                style: TextStyle(color: isUp ? Colors.green : Colors.red),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context, rootNavigator: true).pushNamed(
                      AppRoutes.checkoutRoute,
                      arguments: {
                        'title': item.symbol,
                        'seller': item.sellerName,
                        'amount': item.price,
                      },
                    );
                  },
                  child: const Text('Buy Now'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
