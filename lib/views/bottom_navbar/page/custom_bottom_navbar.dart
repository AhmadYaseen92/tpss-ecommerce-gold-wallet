import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/app_cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/app_cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/cart_cubit/cart_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/cart/page/cart_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/home/page/home_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product/page/product_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/transaction/page/transaction_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/page/gold_wallet_page.dart';

class CustomeBottomNavbar extends StatefulWidget {
  const CustomeBottomNavbar({super.key});

  @override
  State<CustomeBottomNavbar> createState() => _CustomeBottomNavbarState();
}

const _tabTitles = ['Gold Wallet', 'Shop', 'My Wallet', 'My Cart', 'Transactions'];

class _CustomeBottomNavbarState extends State<CustomeBottomNavbar> {
  late final PersistentTabController _controller;
  late final CartCubit cartCubit;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController();
    cartCubit = CartCubit();
  }

  @override
  void dispose() {
    _controller.dispose();
    cartCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<AppCubit>().state.selectedSeller;
    if (cartCubit.state is CartInitial) {
      cartCubit.loadCartProducts(sellerFilter: seller);
    }

    return BlocProvider.value(
      value: cartCubit,
      child: BlocListener<AppCubit, AppState>(
        listenWhen: (previous, current) => previous.selectedSeller != current.selectedSeller,
        listener: (context, state) {
          cartCubit.loadCartProducts(sellerFilter: state.selectedSeller);
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: AppColors.backgroundColor,
            title: Text(
              _tabTitles[_currentTabIndex],
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.accountSummaryRoute),
                icon: const Icon(Icons.account_balance_wallet_outlined),
                tooltip: 'My Account Summary',
              ),
              IconButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.profileRoute),
                icon: const Icon(Icons.person_outline),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notificationRoute),
                icon: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
          body: PersistentTabView(
            onTabChanged: (index) {
              setState(() => _currentTabIndex = index);
              if (index == 3) {
                final currentSeller = context.read<AppCubit>().state.selectedSeller;
                cartCubit.loadCartProducts(sellerFilter: currentSeller);
              }
            },
            controller: _controller,
            backgroundColor: AppColors.backgroundColor,
            tabs: [
              PersistentTabConfig(
                screen: HomePage(),
                item: ItemConfig(
                  icon: const Icon(CupertinoIcons.home),
                  title: 'Home',
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  activeForegroundColor: AppColors.primaryColor,
                  inactiveForegroundColor: AppColors.grey,
                ),
              ),
              PersistentTabConfig(
                screen: const ProductPage(),
                item: ItemConfig(
                  icon: const Icon(CupertinoIcons.bag),
                  title: 'Product',
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  activeForegroundColor: AppColors.primaryColor,
                  inactiveForegroundColor: AppColors.grey,
                ),
              ),
              PersistentTabConfig(
                screen: const GoldWalletPage(),
                item: ItemConfig(
                  icon: const Icon(CupertinoIcons.creditcard, color: AppColors.white),
                  title: 'Wallet',
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey),
                  activeForegroundColor: AppColors.primaryColor,
                  inactiveForegroundColor: AppColors.grey,
                ),
              ),
              PersistentTabConfig(
                screen: const CartPage(),
                item: ItemConfig(
                  icon: const Icon(CupertinoIcons.shopping_cart),
                  title: 'Cart',
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  activeForegroundColor: AppColors.primaryColor,
                  inactiveForegroundColor: AppColors.grey,
                ),
              ),
              PersistentTabConfig(
                screen: const TransactionPage(),
                item: ItemConfig(
                  icon: const Icon(Icons.list_alt),
                  title: 'History',
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  activeForegroundColor: AppColors.primaryColor,
                  inactiveForegroundColor: AppColors.grey,
                ),
              ),
            ],
            stateManagement: true,
            navBarBuilder: (navBarConfig) => Style13BottomNavBar(navBarConfig: navBarConfig),
          ),
        ),
      ),
    );
  }
}
