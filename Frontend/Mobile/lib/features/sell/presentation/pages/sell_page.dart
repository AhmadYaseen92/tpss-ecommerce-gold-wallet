import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/presentation/cubit/sell_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/presentation/widgets/sell_widget.dart';

class SellGoldPage extends StatelessWidget {
  const SellGoldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SellCubit(
          loadSellDataUseCase: InjectionContainer.loadSellDataUseCase(),
          getLiveSellPriceUseCase: InjectionContainer.getLiveSellPriceUseCase(),
          validateSellUseCase: InjectionContainer.validateSellUseCase(),
          submitSellOrderUseCase: InjectionContainer.submitSellOrderUseCase(),
          calculateSellTotalsUseCase: InjectionContainer.calculateSellTotalsUseCase(),
        );
        cubit.loadSellData();
        return cubit;
      },
      child: BlocBuilder<SellCubit, SellState>(
        builder: (context, state) {
          if (state is SellInitial || state is SellLoading) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  'Sell Assets',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.appPalette.primary,
                  ),
                ),
              ),
              body: const Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: AppColors.darkGold,
                ),
              ),
            );
          } else if (state is SellDataChanged) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  'Sell Assets',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.appPalette.primary,
                  ),
                ),
              ),
              body: SellWidget(sellCubit: BlocProvider.of<SellCubit>(context)),
            );
          } else if (state is SellError) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  'Sell Assets',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.appPalette.primary,
                  ),
                ),
              ),
              body: Center(child: Text(state.message)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
