import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_filter_chip.dart';

class SellerFilterBarWidget extends StatelessWidget {
  const SellerFilterBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppReleaseConfig.showSellerUi) {
      return const SizedBox.shrink();
    }
    final selectedSeller = context.watch<AppCubit>().state.selectedSeller;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: AppCubit.supportedSellers.map((seller) {
            final isSelected = seller == selectedSeller;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppFilterChip(
                label: seller,
                selected: isSelected,
                onTap: () => context.read<AppCubit>().setSeller(seller),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
