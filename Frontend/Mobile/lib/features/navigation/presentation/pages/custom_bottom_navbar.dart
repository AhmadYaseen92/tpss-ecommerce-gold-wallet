import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/cart/presentation/pages/cart_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/presentation/pages/home_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/pages/product_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/presentation/pages/transaction_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/pages/gold_wallet_page.dart';

class CustomeBottomNavbar extends StatefulWidget {
  const CustomeBottomNavbar({super.key});

  @override
  State<CustomeBottomNavbar> createState() => _CustomeBottomNavbarState();
}

const _tabTitles = ['Gold Wallet', 'Shop', 'My Wallet', 'My Cart', 'Transactions'];

class _CustomeBottomNavbarState extends State<CustomeBottomNavbar> {
  late final CartCubit cartCubit;
  late final Future<int> Function() _getUnreadCount;
  Timer? _unreadTimer;
  int _currentTabIndex = 0;
  int _unreadCount = 0;

  void _openHistoryTab() {
    setState(() => _currentTabIndex = 4);
  }

  @override
  void initState() {
    super.initState();
    cartCubit = CartCubit(
      getCartItemsUseCase: InjectionContainer.getCartItemsUseCase(),
      addCartProductUseCase: InjectionContainer.addCartProductUseCase(),
      removeCartProductUseCase: InjectionContainer.removeCartProductUseCase(),
      updateCartProductQuantityUseCase: InjectionContainer.updateCartProductQuantityUseCase(),
      cartRepository: InjectionContainer.cartRepository(),
    );
    _getUnreadCount = InjectionContainer.getUnreadNotificationsCountUseCase().call;
    _refreshUnreadCount();
    _unreadTimer = Timer.periodic(const Duration(seconds: 20), (_) => _refreshUnreadCount(showToastOnIncrease: true));
  }

  @override
  void dispose() {
    _unreadTimer?.cancel();
    cartCubit.close();
    super.dispose();
  }

  Future<void> _refreshUnreadCount({bool showToastOnIncrease = false}) async {
    try {
      final nextCount = await _getUnreadCount();
      if (!mounted) return;
      if (showToastOnIncrease && nextCount > _unreadCount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have a new notification')),
        );
      }
      setState(() => _unreadCount = nextCount);
    } catch (_) {
      // Keep previous badge count on transient network issues.
    }
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
          title: Text(
            _tabTitles[_currentTabIndex],
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: palette.primary,
            ),
          ),
          actions: [
            if (AppReleaseConfig.myAccountSummaryEnabled)
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
              onPressed: () async {
                await Navigator.of(context).pushNamed(AppRoutes.notificationRoute);
                await _refreshUnreadCount();
              },
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications_outlined, color: palette.primary),
                  if (_unreadCount > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16),
                        child: Text(
                          _unreadCount > 99 ? '99+' : '$_unreadCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
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
