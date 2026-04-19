import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/presentation/widgets/recent_transactions_common_widget.dart';
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
    final items = transactions
        .map(
          (tx) => RecentTransactionViewModel(
            title: tx.name,
            subtitle: tx.subtitle,
            amountText: tx.marketValue,
            isPositive: tx.change.startsWith('+'),
            imageUrl: tx.imageUrl,
            secondaryText: (tx.statusDetails ?? '').trim().isNotEmpty
                ? tx.statusDetails
                : 'Investment: \$${tx.investmentValue.toStringAsFixed(2)}',
          ),
        )
        .toList();

    return RecentTransactionsCommonWidget(
      title: 'My Transactions',
      transactions: items,
      onViewAllHistory: onViewAllHistory,
      maxItems: 3,
      viewAllColor: accentColor,
    );
  }
}
