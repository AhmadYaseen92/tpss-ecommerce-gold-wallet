import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/presentation/widgets/PortfolioCardWidget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_card_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_tab_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_transactions_widget.dart';

class GoldWalletPage extends StatelessWidget {
  const GoldWalletPage({super.key, required this.onViewAllHistory});

  final VoidCallback onViewAllHistory;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        WalletCubit walletCubit = WalletCubit(
          loadWalletsUseCase: InjectionContainer.loadWalletsUseCase(),
          watchWalletsUseCase: InjectionContainer.watchWalletsUseCase(),
        );
        walletCubit.loadWallets();
        return walletCubit;
      },
      child: BlocListener<AppCubit, AppState>(
        listenWhen: (previous, current) =>
            previous.checkoutRefreshTick != current.checkoutRefreshTick,
        listener: (context, _) {
          context.read<WalletCubit>().loadWallets();
        },
        child: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            if (state is WalletInitial || state is WalletLoading) {
              return const Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: AppColors.darkGold,
                ),
              );
            }
            if (state is WalletLoaded) {
              if (state.wallets.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => context.read<WalletCubit>().loadWallets(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text('No wallet assets for selected category.'),
                      ),
                    ],
                  ),
                );
              }
              final wallet = state.wallets.first;
              final totalPortfolioValue = state.wallets.fold<double>(
                0,
                (sum, item) =>
                    sum +
                    (double.tryParse(
                          item.totalMarketValue.replaceAll(
                            RegExp(r'[^0-9.]'),
                            '',
                          ),
                        ) ??
                        0),
              );
              return RefreshIndicator(
                onRefresh: () => context.read<WalletCubit>().loadWallets(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      PortfolioCardWidget(
                        title: 'Total Portfolio Value',
                        value: '\$${totalPortfolioValue.toStringAsFixed(2)}',
                        change: '${wallet.change} live',
                        availableCash: '\$2,000.00',
                      ),
                      const SizedBox(height: 20.0),

                      WalletTabBar(
                        selectedCategoryId: state.selectedCategoryId,
                        onCategoryTap: (categoryId) =>
                            context.read<WalletCubit>().selectCategory(
                              categoryId,
                            ),
                      ),
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
                          accentColor: context.appPalette.primary,
                          onViewAllHistory: onViewAllHistory,
                        ),
                    ],
                  ),
                ),
              );
            }
            if (state is WalletError) {
              return Scaffold(
                appBar: AppBar(title: const Text("Wallet")),
                body: Center(child: Text(state.message)),
              );
            }
            return const SizedBox.shrink();
          }
        ),
      ),
    );
  }
}
