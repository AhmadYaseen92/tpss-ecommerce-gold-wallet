import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_filter_chip.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/empty_state_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/helpers/product_category_filter.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/presentation/widgets/PortfolioCardWidget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/presentation/widgets/summary_transaction_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_card_widget.dart';

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
              final totalPortfolioValue = state.totalPortfolioValue;
              final currencyCode = _extractCurrencyCode(wallet.totalMarketValue);
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
                        value: '$currencyCode ${totalPortfolioValue.toStringAsFixed(2)}',
                        change: '',
                        availableCash: wallet.cashBalance,
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ProductCategoryFilter.options
                              .where((category) => category.categoryId != null)
                              .map((category) {
                            final isSelected = state.selectedCategoryId == category.categoryId;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: AppFilterChip(
                                label: category.label,
                                selected: isSelected,
                                onTap: () => context.read<WalletCubit>().selectCategory(category.categoryId),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      WalletCardWidget(
                        category: wallet.category,
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
                        SummaryTransactionWidget(
                          title: 'My Transactions',
                          onViewAllHistory: onViewAllHistory,
                        )
                      else
                        EmptyStateWidget(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'No Wallet Details',
                          message: 'You haven\'t added any items to your wallet yet. Start by adding your first gold item.',

                        ),
                    ],
                  ),
                ),
              );
            }
            if (state is WalletError) {
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: const Text(
                    'Wallet',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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

String _extractCurrencyCode(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'USD';
  final firstToken = trimmed.split(RegExp(r'\s+')).first.trim().toUpperCase();
  return firstToken.length == 3 ? firstToken : 'USD';
}
