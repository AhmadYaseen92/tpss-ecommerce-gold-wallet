import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/data/market_order_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/models/market_order_model.dart';

class MarketOrderListPage extends StatefulWidget {
  const MarketOrderListPage({super.key});

  @override
  State<MarketOrderListPage> createState() => _MarketOrderListPageState();
}

class _MarketOrderListPageState extends State<MarketOrderListPage> {
  @override
  Widget build(BuildContext context) {
    final orders = MarketOrderRepository.orders;

    return Scaffold(
      appBar: AppBar(title: const Text('My Market Orders'), centerTitle: true),
      body: orders.isEmpty
          ? const Center(child: Text('No orders yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, index) {
                final order = orders[index];
                return Card(
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
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            _statusChip(context, order.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Seller: ${order.seller}'),
                        Text('Qty: ${order.quantity} • Unit: \$${order.unitPrice.toStringAsFixed(2)}'),
                        Text('Payment: ${order.paymentMethod}'),
                        Text('Total: \$${order.total.toStringAsFixed(2)}'),
                        const SizedBox(height: 10),
                        if (order.status == MarketOrderStatus.rejected)
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  MarketOrderRepository.reopenRejectedOrder(order.id);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reopen'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  MarketOrderRepository.cancelOrder(order.id);
                                  setState(() {});
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
              itemCount: orders.length,
            ),
    );
  }

  Widget _statusChip(BuildContext context, MarketOrderStatus status) {
    final palette = context.appPalette;
    switch (status) {
      case MarketOrderStatus.pending:
        return Chip(label: const Text('Pending'), backgroundColor: palette.surfaceMuted);
      case MarketOrderStatus.filled:
        return const Chip(label: Text('Filled'), backgroundColor: Color(0xFFD9F6DF));
      case MarketOrderStatus.rejected:
        return const Chip(label: Text('Rejected'), backgroundColor: Color(0xFFFFE0E0));
      case MarketOrderStatus.cancelled:
        return const Chip(label: Text('Cancelled'), backgroundColor: Color(0xFFF0F0F0));
    }
  }
}
