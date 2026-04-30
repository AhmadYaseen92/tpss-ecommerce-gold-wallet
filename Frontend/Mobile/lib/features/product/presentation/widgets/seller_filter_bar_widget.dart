import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_filter_chip.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/cubit/product_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/l10n/generated/app_localizations.dart';

class SellerFilterBarWidget extends StatelessWidget {
  const SellerFilterBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppReleaseConfig.showSellerUi) {
      return const SizedBox.shrink();
    }
    final selectedSeller = context.watch<AppCubit>().state.selectedSeller;
    final productCubit = context.watch<ProductCubit>();
    final dynamicSellers = productCubit.allProducts
        .map((product) => product.sellerName.trim())
        .where((seller) => seller.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final sellers = [
      AppReleaseConfig.allSellersLabel,
      ...dynamicSellers,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: sellers.map((seller) {
            final isSelected = seller == selectedSeller;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppFilterChip(
                label: _displaySellerLabel(context, seller),
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
