import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/presentation/widgets/recent_transactions_common_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/empty_state_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';

class WalletTransactionsWidget extends StatelessWidget {
  const WalletTransactionsWidget({
    super.key,
    required this.transactions,
    required this.accentColor,
    required this.onViewAllHistory,
  });

  final List<WalletTransactionEntity> transactions;
  final Color accentColor;
  final VoidCallback onViewAllHistory;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    if (transactions.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.history,
        title: 'No Transactions Yet',
        message:
            'Your transaction history will appear here when you add items to your wallet.',
      );
    }

    final items = transactions.map((tx) {
      final pnl = tx.marketValueAmount - tx.estimatedPurchaseValue;
      final isPositive = pnl >= 0;

      return RecentTransactionViewModel(
        title: tx.name,
        subtitle: tx.subtitle,
        amountText: tx.marketValue,
        isPositive: isPositive,
      );
    }).toList();

    return RecentTransactionsCommonWidget(
      title: 'My Transactions',
      transactions: items,
      onViewAllHistory: onViewAllHistory,
      maxItems: 3,
      viewAllColor: accentColor,
    );
  }
}