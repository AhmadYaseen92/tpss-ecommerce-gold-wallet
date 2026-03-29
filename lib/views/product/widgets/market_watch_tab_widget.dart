import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/models/market_symbol_model.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/product_cubit/product_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product/widgets/seller_filter_bar_widget.dart';

class MarketWatchTabWidget extends StatelessWidget {
  const MarketWatchTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      buildWhen: (_, current) =>
          current is ProductMarketWatchLoaded || current is ProductLoaded,
      builder: (context, state) {
        final cubit = context.read<ProductCubit>();
        final symbols = state is ProductMarketWatchLoaded
            ? state.symbols
            : cubit.visibleMarketSymbols;

        return Column(
          children: [
            const SellerFilterBarWidget(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: symbols.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = symbols[index];
                  final isUp = item.change >= 0;
                  return Card(
                    color: AppColors.white,
                    child: GestureDetector(
                      onTap: () => _openMarketDetail(context, item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// LEFT SIDE (Title + Subtitle)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.symbol,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(item.name),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Seller: ${item.sellerName}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.darkGold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// RIGHT SIDE (Price + Change)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '\$${item.price.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${isUp ? '+' : ''}${item.change.toStringAsFixed(2)}%',
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        color: isUp ? Colors.green : Colors.red,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
              Text(
                item.symbol,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text('${item.name} • Seller: ${item.sellerName}'),
              const SizedBox(height: 12),
              Text(
                'Live Price: \$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18),
              ),
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
                      AppRoutes.marketOrderCheckoutRoute,
                      arguments: {
                        'title': item.symbol,
                        'seller': item.sellerName,
                        'amount': item.price,
                      },
                    );
                  },
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
