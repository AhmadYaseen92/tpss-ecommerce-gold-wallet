import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/app_cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/wallet_cubit/wallet_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/home/widgets/PortfolioCardWidget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_card_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_tab_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_transactions_widget.dart';

class GoldWalletPage extends StatelessWidget {
  const GoldWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        WalletCubit walletCubit = WalletCubit();
        walletCubit.loadWallets();
        return walletCubit;
      },
      child: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletInitial || state is WalletLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: AppColors.darkGold,
              ),
            );
          } else if (state is WalletLoaded) {
            final wallet = state.wallets[state.selectedIndex];
            final seller = context.watch<AppCubit>().state.selectedSeller;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.luxuryIvory,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      seller == 'All Sellers' ? 'Wallet scope: all sellers' : 'Wallet scope: $seller',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PortfolioCardWidget(
                    title: 'Total Portfolio Value',
                    value: '\$12,450.00',
                    change: '+\$125 (1.01%)',
                    availableCash: '\$2,000.00',
                  ),
                  const SizedBox(height: 20.0),

                  WalletTabBar(selectedIndex: state.selectedIndex),
                  const SizedBox(height: 16.0),

                  WalletCardWidget(
                    walletName: wallet.walletName,
                    isVerified: wallet.isVerified,
                    totalWeightInGrams: wallet.totalWeightInGrams,
                    totalWeightInKg: wallet.totalWeightInKg,
                    totalWeightInOz: wallet.totalWeightInOz,
                    totalMarketValue: wallet.totalMarketValue,
                    totalHoldings: wallet.totalHoldings,
                    change: wallet.change,
                    icon: wallet.icon,
                    transactions: wallet.transactions,
                    note: wallet.note,
                  ),

                  const SizedBox(height: 20.0),
                  if (wallet.transactions.isNotEmpty)
                    WalletTransactionsWidget(
                      transactions: wallet.transactions,
                      accentColor: AppColors.primaryColor,
                    ),
                ],
              ),
            );
          } else if (state is WalletError) {
            return Scaffold(
              appBar: AppBar(title: const Text("Wallet")),
              body: Center(child: Text(state.message)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
