import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
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
    final palette = context.appPalette;
    final seller = context.watch<AppCubit>().state.selectedSeller;
    if (cartCubit.state is CartInitial) {
      cartCubit.loadCartProducts(sellerFilter: seller);
    }

    return BlocProvider.value(
      value: cartCubit,
      child: BlocListener<AppCubit, AppState>(
        listenWhen: (previous, current) => previous.selectedSeller != current.selectedSeller,
        listener: (context, state) => cartCubit.loadCartProducts(sellerFilter: state.selectedSeller),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(_tabTitles[_currentTabIndex], style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: palette.primary)),
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.accountSummaryRoute),
                icon: Icon(Icons.account_balance_wallet_outlined, color: palette.textPrimary),
                tooltip: 'My Account Summary',
              ),
              IconButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.profileRoute),
                icon: Icon(Icons.person_outline, color: palette.textPrimary),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notificationRoute),
                icon: Icon(Icons.notifications_outlined, color: palette.textPrimary),
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            tabs: [
              PersistentTabConfig(screen: HomePage(), item: ItemConfig(icon: const Icon(CupertinoIcons.home), title: 'Home', textStyle: const TextStyle(fontWeight: FontWeight.w600), activeForegroundColor: palette.primary, inactiveForegroundColor: palette.textSecondary)),
              PersistentTabConfig(screen: const ProductPage(), item: ItemConfig(icon: const Icon(CupertinoIcons.bag), title: 'Product', textStyle: const TextStyle(fontWeight: FontWeight.w600), activeForegroundColor: palette.primary, inactiveForegroundColor: palette.textSecondary)),
              PersistentTabConfig(screen: const GoldWalletPage(), item: ItemConfig(icon: Icon(CupertinoIcons.creditcard, color: palette.surface), title: 'Wallet', textStyle: TextStyle(fontWeight: FontWeight.w600, color: palette.textSecondary), activeForegroundColor: palette.primary, inactiveForegroundColor: palette.textSecondary)),
              PersistentTabConfig(screen: const CartPage(), item: ItemConfig(icon: const Icon(CupertinoIcons.shopping_cart), title: 'Cart', textStyle: const TextStyle(fontWeight: FontWeight.w600), activeForegroundColor: palette.primary, inactiveForegroundColor: palette.textSecondary)),
              PersistentTabConfig(screen: const TransactionPage(), item: ItemConfig(icon: const Icon(Icons.list_alt), title: 'History', textStyle: const TextStyle(fontWeight: FontWeight.w600), activeForegroundColor: palette.primary, inactiveForegroundColor: palette.textSecondary)),
            ],
            stateManagement: true,
            navBarBuilder: (navBarConfig) => Style13BottomNavBar(navBarConfig: navBarConfig),
          ),
        ),
      ),
    );
  }
}
