import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/cart_cubit/cart_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/cart/page/cart_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/transaction/page/transaction_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/page/gold_wallet_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/home/page/home_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product/page/product_page.dart';

class CustomeBottomNavbar extends StatefulWidget {
  const CustomeBottomNavbar({super.key});

  @override
  State<CustomeBottomNavbar> createState() => _CustomeBottomNavbarState();
}

const _tabTitles = [
  'Gold Wallet',
  'Shop',
  'My Wallet',
  'My Cart',
  'Transactions',
];

class _CustomeBottomNavbarState extends State<CustomeBottomNavbar> {
  late final PersistentTabController _controller;
  late final CartCubit cartCubit;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController();
    cartCubit = CartCubit()..loadCartProducts();
  }

  @override
  void dispose() {
    _controller.dispose();
    cartCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cartCubit,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: Center(
            child: Text(
              _tabTitles[_currentTabIndex],
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.person_outline)),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_outlined),
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: AppColors.greysShade2,
          child: Center(child: Text('Navigation Drawer')),
        ),
        body: PersistentTabView(
          onTabChanged: (index) {
            setState(() => _currentTabIndex = index);
            if (index == 3) {
              cartCubit.loadCartProducts();
            }
          },
          controller: _controller,
          backgroundColor: AppColors.backgroundColor,
          tabs: [
            PersistentTabConfig(
              screen: HomePage(),
              item: ItemConfig(
                icon: Icon(CupertinoIcons.home),
                title: "Home",
                textStyle: TextStyle(fontWeight: FontWeight.w600),
                activeForegroundColor: AppColors.primaryColor,
                inactiveForegroundColor: AppColors.grey,
              ),
            ),
            PersistentTabConfig(
              screen: ProductPage(),
              item: ItemConfig(
                icon: Icon(CupertinoIcons.bag),
                title: "Product",
                textStyle: TextStyle(fontWeight: FontWeight.w600),
                activeForegroundColor: AppColors.primaryColor,
                inactiveForegroundColor: AppColors.grey,
              ),
            ),
            PersistentTabConfig(
              screen: GoldWalletPage(),
              item: ItemConfig(
                icon: Icon(CupertinoIcons.creditcard),
                title: "Wallet",
                textStyle: TextStyle(fontWeight: FontWeight.w600),
                activeForegroundColor: AppColors.gold,
                inactiveForegroundColor: AppColors.grey,
              ),
            ),
            PersistentTabConfig(
              screen: CartPage(),
              item: ItemConfig(
                icon: Icon(CupertinoIcons.shopping_cart),
                title: "Cart",
                textStyle: TextStyle(fontWeight: FontWeight.w600),
                activeForegroundColor: AppColors.primaryColor,
                inactiveForegroundColor: AppColors.grey,
              ),
            ),
            PersistentTabConfig(
              screen: TransactionPage(),
              item: ItemConfig(
                icon: Icon(Icons.list_alt),
                title: "History",
                textStyle: TextStyle(fontWeight: FontWeight.w600),
                activeForegroundColor: AppColors.primaryColor,
                inactiveForegroundColor: AppColors.grey,
              ),
            ),
          ],
          stateManagement: true,
          navBarBuilder: (navBarConfig) =>
              Style13BottomNavBar(navBarConfig: navBarConfig),
        ),
      ),
    );
  }
}
