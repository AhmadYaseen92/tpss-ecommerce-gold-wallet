import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_release_config.dart';
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
                                  if (AppReleaseConfig.showSellerUi) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Seller: ${item.sellerName}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.darkGold,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    'Updated: ${_formatUpdatedTime(DateTime.now())}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// RIGHT SIDE (Ask/Bid/High/Low)
                            SizedBox(
                              width: 150,
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _marketValueLine(
                                  context,
                                  label: 'Ask',
                                  value: _ask(item).toStringAsFixed(2),
                                ),
                                _marketValueLine(
                                  context,
                                  label: 'Bid',
                                  value: _bid(item).toStringAsFixed(2),
                                ),
                                _marketValueLine(
                                  context,
                                  label: 'High',
                                  value: _high(item).toStringAsFixed(2),
                                ),
                                _marketValueLine(
                                  context,
                                  label: 'Low',
                                  value: _low(item).toStringAsFixed(2),
                                ),
                              ],
                            ),
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
              Text(
                AppReleaseConfig.showSellerUi
                    ? '${item.name} • Seller: ${item.sellerName}'
                    : item.name,
              ),
              const SizedBox(height: 12),
              Text(
                'Live Price: \$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'Ask ${_ask(item).toStringAsFixed(2)} • Bid ${_bid(item).toStringAsFixed(2)}',
              ),
              Text('High ${_high(item).toStringAsFixed(2)} • Low ${_low(item).toStringAsFixed(2)}'),
              const SizedBox(height: 4),
              Text(
                'Updated: ${_formatUpdatedTime(DateTime.now())}',
                style: const TextStyle(color: AppColors.grey),
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

  Widget _marketValueLine(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(color: AppColors.grey),
            ),
            TextSpan(
              text: '\$$value',
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatUpdatedTime(DateTime time) {
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final year = time.year.toString();
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    final millisecond = time.millisecond.toString().padLeft(3, '0');
    return '$year-$month-$day $hour:$minute:$second.$millisecond';
  }

  double _ask(MarketSymbolModel item) => item.price * 1.0015;
  double _bid(MarketSymbolModel item) => item.price * 0.9985;
  double _high(MarketSymbolModel item) => item.price * 1.01;
  double _low(MarketSymbolModel item) => item.price * 0.99;
}
