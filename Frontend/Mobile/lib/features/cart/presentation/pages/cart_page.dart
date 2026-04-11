import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/presentation/widgets/cart_item_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/presentation/widgets/cart_summary.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? _selectedSeller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final cartCubit = BlocProvider.of<CartCubit>(context);
              if (state is CartInitial || state is CartLoading) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: AppColors.darkGold,
                  ),
                );
              } else if (state is CartLoaded) {
                final cartProducts = state.cartProducts;
                final sellers = state.availableSellers;
                if (AppReleaseConfig.showSellerUi && sellers.isNotEmpty) {
                  _selectedSeller ??= state.selectedSellerFilter;
                }
                if (cartProducts.isEmpty) {
                  return Center(
                    child: Text(
                      AppReleaseConfig.showSellerUi
                          ? 'Your cart is empty for selected seller'
                          : 'Your cart is empty',
                    ),
                  );
                }
                return Column(
                  children: [
                    if (AppReleaseConfig.showSellerUi && sellers.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: sellers.map((seller) {
                              final isSelected = _selectedSeller == seller;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(seller),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() => _selectedSeller = seller);
                                    cartCubit.loadCartProducts(sellerFilter: seller);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => cartCubit.loadCartProducts(
                          sellerFilter: _selectedSeller ?? state.selectedSellerFilter,
                        ),
                        child: CartItemWidget(
                          cartCubit: cartCubit,
                          cartProducts: cartProducts,
                        ),
                      ),
                    ),
                    CartSummary(summary: state.summary),
                  ],
                );
              } else if (state is CartError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
