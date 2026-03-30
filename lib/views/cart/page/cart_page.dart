import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/cart_cubit/cart_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/cart/widgets/cart_item_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/cart/widgets/cart_summary.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartInitial || state is CartLoading) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: AppColors.darkGold,
                  ),
                );
              } else if (state is CartLoaded) {
                final cartProducts = state.cartProducts;
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
                    Expanded(
                      child: CartItemWidget(
                        cartCubit: BlocProvider.of<CartCubit>(context),
                        cartProducts: cartProducts,
                      ),
                    ),
                    CartSummary(cartCubit: BlocProvider.of<CartCubit>(context)),
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
