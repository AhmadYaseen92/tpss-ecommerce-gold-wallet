import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/presentation/cubit/cart_cubit.dart';
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
  late final CartCubit cartCubit;
  int _currentTabIndex = 0;

  void _openHistoryTab() {
    setState(() => _currentTabIndex = 4);
  }

  @override
  void initState() {
    super.initState();
    cartCubit = CartCubit();
  }

  @override
  void dispose() {
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

    final screens = [
      HomePage(onViewAllHistory: _openHistoryTab),
      const ProductPage(),
      GoldWalletPage(onViewAllHistory: _openHistoryTab),
      BlocProvider.value(value: cartCubit, child: const CartPage()),
      const TransactionPage(),
    ];

    return BlocListener<AppCubit, AppState>(
      listenWhen: (previous, current) => previous.selectedSeller != current.selectedSeller,
      listener: (context, state) => cartCubit.loadCartProducts(sellerFilter: state.selectedSeller),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            _tabTitles[_currentTabIndex],
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: palette.primary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.accountSummaryRoute),
              icon: Icon(Icons.account_balance_wallet_outlined, color: palette.primary),
              tooltip: 'My Account Summary',
            ),
            IconButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.profileRoute),
              icon: Icon(Icons.person_outline, color: palette.primary),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notificationRoute),
              icon: Icon(Icons.notifications_outlined, color: palette.primary),
            ),
          ],
        ),
        body: IndexedStack(index: _currentTabIndex, children: screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: palette.surface,
          selectedItemColor: palette.primary,
          unselectedItemColor: palette.textSecondary,
          onTap: (index) {
            setState(() => _currentTabIndex = index);
            if (index == 3) {
              final currentSeller = context.read<AppCubit>().state.selectedSeller;
              cartCubit.loadCartProducts(sellerFilter: currentSeller);
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.bag), label: 'Product'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.creditcard), label: 'Wallet'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'History'),
          ],
        ),
      ),
    );
  }
}
