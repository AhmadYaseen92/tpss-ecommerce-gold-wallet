import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/market_orders/domain/entities/market_order_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/grams_hint_label.dart';
import 'package:tpss_ecommerce_gold_wallet/features/market_orders/presentation/cubit/market_order_cubit.dart';

class MarketOrderListPage extends StatelessWidget {
  const MarketOrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My Market Orders',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const MarketOrderListView(showStatusFilter: true),
    );
  }
}

class MarketOrderListView extends StatelessWidget {
  const MarketOrderListView({
    super.key,
    this.sellerFilter = AppReleaseConfig.defaultAllSellersLabel,
    this.showStatusFilter = false,
  });

  final String sellerFilter;
  final bool showStatusFilter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MarketOrderCubit(
            repository: InjectionContainer.marketOrderRepository(),
          )..load(sellerFilter: sellerFilter),
      child: _MarketOrderListContent(showStatusFilter: showStatusFilter),
    );
  }
}

class _MarketOrderListContent extends StatelessWidget {
  const _MarketOrderListContent({required this.showStatusFilter});

  final bool showStatusFilter;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MarketOrderCubit>();

    return BlocBuilder<MarketOrderCubit, MarketOrderState>(
      builder: (context, state) {
        if (state is MarketOrderInitial || state is MarketOrderLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (state is MarketOrderError) {
          return Center(child: Text(state.message));
        }

        final loaded = state as MarketOrderLoaded;
        return Column(
          children: [
            if (showStatusFilter)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: MarketOrderStatusFilter.values.map((status) {
                      final selected = status == loaded.statusFilter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_statusLabel(status)),
                          selected: selected,
                          onSelected: (_) => cubit.setStatusFilter(status),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            Expanded(
              child: loaded.orders.isEmpty
                  ? const Center(child: Text('No orders for selected filters.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (_, index) {
                        final order = loaded.orders[index];
                        final totalWeight =
                            GramsConverter.fromSymbol(order.symbol) *
                            order.quantity;
                        return Card(
                          color: Theme.of(context).cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${order.symbol} • ${order.id}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    _statusChip(context, order.status),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Seller: ${order.seller}'),
                                Text(
                                  'Qty: ${order.quantity} • Unit: \$${order.unitPrice.toStringAsFixed(2)}',
                                ),
                                if (AppReleaseConfig.showWeightInGrams)
                                  GramsHintLabel(
                                    grams: totalWeight,
                                    prefix: 'Weight:',
                                  ),
                                Text('Payment: ${order.paymentMethod}'),
                                Text('Account: ${order.paymentAccount}'),
                                Text(
                                  'Total: \$${order.total.toStringAsFixed(2)}',
                                ),
                                const SizedBox(height: 10),
                                if (order.status == MarketOrderStatus.pending)
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.hourglass_top_rounded,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Waiting for payment provider result...',
                                      ),
                                    ],
                                  ),
                                if (order.status == MarketOrderStatus.rejected)
                                  Row(
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          final livePrice = cubit.livePriceForSymbol(
                                            order.symbol,
                                            fallback: order.unitPrice,
                                          );
                                          final goToOrders =
                                              await Navigator.pushNamed(
                                                context,
                                                AppRoutes
                                                    .marketOrderCheckoutRoute,
                                                arguments: {
                                                  'title': order.symbol,
                                                  'seller': order.seller,
                                                  'amount': livePrice,
                                                  'reopenOrderId': order.id,
                                                },
                                              );
                                          if (goToOrders == true &&
                                              context.mounted) {
                                            cubit.load(
                                              sellerFilter: loaded.sellerFilter,
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Reopen'),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          cubit.cancelOrder(order.id);
                                        },
                                        icon: const Icon(Icons.cancel_outlined),
                                        label: const Text('Cancel'),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: loaded.orders.length,
                    ),
            ),
          ],
        );
      },
    );
  }

  String _statusLabel(MarketOrderStatusFilter filter) {
    switch (filter) {
      case MarketOrderStatusFilter.all:
        return 'All';
      case MarketOrderStatusFilter.pending:
        return 'Pending';
      case MarketOrderStatusFilter.filled:
        return 'Filled';
      case MarketOrderStatusFilter.rejected:
        return 'Rejected';
      case MarketOrderStatusFilter.cancelled:
        return 'Cancelled';
    }
  }

  Widget _statusChip(BuildContext context, MarketOrderStatus status) {
    final palette = context.appPalette;
    switch (status) {
      case MarketOrderStatus.pending:
        return Chip(
          label: const Text('Pending'),
          backgroundColor: palette.surfaceMuted,
        );
      case MarketOrderStatus.filled:
        return const Chip(
          label: Text('Filled'),
          backgroundColor: Color(0xFFD9F6DF),
        );
      case MarketOrderStatus.rejected:
        return const Chip(
          label: Text('Rejected'),
          backgroundColor: Color(0xFFFFE0E0),
        );
      case MarketOrderStatus.cancelled:
        return const Chip(
          label: Text('Cancelled'),
          backgroundColor: Color(0xFFF0F0F0),
        );
    }
  }
}
