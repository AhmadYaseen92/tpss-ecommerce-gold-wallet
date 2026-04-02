import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
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
  }) {
    var order = MarketOrderModel(
      id: 'MO-${_nextOrderId++}',
      symbol: symbol,
      seller: seller,
      quantity: quantity,
      unitPrice: unitPrice,
      paymentMethod: paymentMethod,
      status: MarketOrderStatus.pending,
      createdAt: DateTime.now(),
    );

    final total = order.total;
    if (availableCashBalance < total) {
      order = order.copyWith(status: MarketOrderStatus.rejected);
      _orders.add(order);
      todayNotifications.insert(
        0,
        NotificationModel(
          title: 'Pending Order Rejected',
          description: 'Insufficient balance for ${order.symbol}. Please add funds and reopen order ${order.id}.',
          dateTime: DateTime.now(),
          icon: const Icon(Icons.warning_amber_rounded, color: AppColors.red),
        ),
      );
      return order;
    }

    availableCashBalance -= total;
    order = order.copyWith(status: MarketOrderStatus.filled);
    _orders.add(order);
    _addToWallet(order);

    todayNotifications.insert(
      0,
      NotificationModel(
        title: 'Market Order Filled',
        description: 'Order ${order.id} filled. \$${total.toStringAsFixed(2)} deducted directly and added to wallet.',
        dateTime: DateTime.now(),
        icon: const Icon(Icons.check_circle, color: AppColors.green),
      ),
    );

    return order;
  }

  static MarketOrderModel? reopenRejectedOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return null;
    final order = _orders[index];
    if (order.status != MarketOrderStatus.rejected) return order;

    if (availableCashBalance < order.total) {
      todayNotifications.insert(
        0,
        NotificationModel(
          title: 'Order Still Rejected',
          description: 'Order ${order.id} still has no balance coverage.',
          dateTime: DateTime.now(),
          icon: const Icon(Icons.error_outline, color: AppColors.red),
        ),
      );
      return order;
    }

    availableCashBalance -= order.total;
    final filled = order.copyWith(status: MarketOrderStatus.filled);
    _orders[index] = filled;
    _addToWallet(filled);
    return filled;
  }

  static void cancelOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;
    _orders[index] = _orders[index].copyWith(status: MarketOrderStatus.cancelled);
  }

  static void _addToWallet(MarketOrderModel order) {
    final goldWalletIndex = dummyWallets.indexWhere((wallet) => wallet.category == WalletCategory.gold);
    if (goldWalletIndex == -1) return;

    final wallet = dummyWallets[goldWalletIndex];
    final tx = WalletTransaction(
      name: 'Spot MR ${order.symbol}',
      category: WalletCategory.gold,
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
