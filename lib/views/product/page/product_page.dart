import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/app_cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/app_cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/product_cubit/product_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product/widgets/catalog_tab_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product/widgets/market_watch_tab_widget.dart';

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
          listenWhen: (previous, current) =>
              previous.selectedSeller != current.selectedSeller,
          listener: (context, state) {
            context.read<ProductCubit>().onGlobalSellerChanged(
              state.selectedSeller,
            );
          },
          child: Column(
            children: [
              TabBar(
                labelStyle: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: AppColors.grey,
                indicatorColor: AppColors.primaryColor,
                tabs: [
                  Tab(text: 'Catalog'),
                  Tab(text: 'Market Watch'),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  children: [CatalogTabWidget(), MarketWatchTabWidget()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
