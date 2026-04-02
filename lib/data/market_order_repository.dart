import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/models/market_symbol_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/market_order_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/notification_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';

class MarketOrderRepository {
  static double availableCashBalance = 2000;
  static int _nextOrderId = 1;
  static final List<MarketOrderModel> _orders = <MarketOrderModel>[];

  static List<MarketOrderModel> get orders => List.unmodifiable(_orders.reversed);

  static MarketOrderModel placeOrder({
    required String symbol,
    required String seller,
    required int quantity,
    required double unitPrice,
    required String paymentMethod,
    required String paymentAccount,
  }) {
    final order = MarketOrderModel(
      id: 'MO-${_nextOrderId++}',
      symbol: symbol,
      seller: seller,
      quantity: quantity,
      unitPrice: unitPrice,
      paymentMethod: paymentMethod,
      paymentAccount: paymentAccount,
      status: MarketOrderStatus.pending,
      createdAt: DateTime.now(),
    );
    _orders.add(order);
    todayNotifications.insert(
      0,
      NotificationModel(
        title: 'Market Order Pending',
        description: 'Order ${order.id} submitted and now pending settlement.',
        dateTime: DateTime.now(),
        icon: const Icon(Icons.hourglass_top_rounded, color: AppColors.amber),
      ),
    );
    return order;
  }

  static MarketOrderModel? settleOrder(String orderId, {required bool approve}) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return null;
    final order = _orders[index];
    if (order.status != MarketOrderStatus.pending) return order;

    if (!approve) {
      final rejected = order.copyWith(status: MarketOrderStatus.rejected);
      _orders[index] = rejected;
      todayNotifications.insert(
        0,
        NotificationModel(
          title: 'Order Rejected',
          description: 'Order ${order.id} was rejected by payment provider.',
          dateTime: DateTime.now(),
          icon: const Icon(Icons.error_outline, color: AppColors.red),
        ),
      );
      return rejected;
    }

    if (order.paymentMethod == 'Cash Balance' && availableCashBalance < order.total) {
      final rejected = order.copyWith(status: MarketOrderStatus.rejected);
      _orders[index] = rejected;
      todayNotifications.insert(
        0,
        NotificationModel(
          title: 'Pending Order Rejected',
          description: 'Insufficient cash balance for ${order.symbol}.',
          dateTime: DateTime.now(),
          icon: const Icon(Icons.warning_amber_rounded, color: AppColors.red),
        ),
      );
      return rejected;
    }

    if (order.paymentMethod == 'Cash Balance') {
      availableCashBalance -= order.total;
    }
    final filled = order.copyWith(status: MarketOrderStatus.filled);
    _orders[index] = filled;
    _addToWallet(filled);

    todayNotifications.insert(
      0,
      NotificationModel(
        title: 'Order Completed',
        description: 'Order ${order.id} completed and added to Spot MR wallet.',
        dateTime: DateTime.now(),
        icon: const Icon(Icons.check_circle, color: AppColors.green),
      ),
    );

    return filled;
  }

  static MarketOrderModel? reopenOrderAsPending({
    required String orderId,
    required double liveUnitPrice,
    required int quantity,
    required String paymentMethod,
    required String paymentAccount,
  }) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return null;
    final order = _orders[index];
    if (order.status != MarketOrderStatus.rejected) return order;

    final reopened = order.copyWith(
      status: MarketOrderStatus.pending,
      unitPrice: liveUnitPrice,
      quantity: quantity,
      paymentMethod: paymentMethod,
      paymentAccount: paymentAccount,
    );
    _orders[index] = reopened;
    return reopened;
  }

  static void cancelOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;
    _orders[index] = _orders[index].copyWith(status: MarketOrderStatus.cancelled);
  }

  static double livePriceForSymbol(String symbol, {double fallback = 0}) {
    final match = initialMarketSymbols.where((item) => item.symbol == symbol);
    if (match.isEmpty) return fallback;
    return match.first.price;
  }

  static void _addToWallet(MarketOrderModel order) {
    final goldWalletIndex = dummyWallets.indexWhere((wallet) => wallet.category == WalletCategory.spotMr);
    if (goldWalletIndex == -1) return;

    final wallet = dummyWallets[goldWalletIndex];
    final tx = WalletTransaction(
      name: 'Spot MR ${order.symbol}',
      category: WalletCategory.spotMr,
      assetType: AssetType.gram,
      subtitle: '${order.quantity} unit • Spot MR',
      weightInGrams: order.quantity.toDouble(),
      purity: '999.9',
      quantity: order.quantity,
      marketValue: '\$${order.total.toStringAsFixed(2)}',
      change: '+0.00%',
      sellerName: order.seller,
      imageUrl: 'https://images.unsplash.com/photo-1610375461246-83df859d849d?q=80&w=800',
      isSpotMrOrder: true,
    );

    final updatedTx = [tx, ...wallet.transactions];
    final nextTotal = updatedTx.fold<double>(0, (sum, item) => sum + item.marketValueAmount);
    dummyWallets[goldWalletIndex] = wallet.copyWith(
      transactions: updatedTx,
      totalHoldings: updatedTx.length,
      totalMarketValue: '\$${nextTotal.toStringAsFixed(2)}',
      totalWeightInGrams: updatedTx.fold<double>(0, (sum, item) => sum + item.weightInGrams),
    );
  }
}
