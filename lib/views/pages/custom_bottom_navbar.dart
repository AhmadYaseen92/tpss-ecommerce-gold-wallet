import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/views/pages/cart_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/pages/favorite_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/pages/gold_wallet_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/pages/home_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/pages/product_page.dart';

class CustomeBottomNavbar extends StatefulWidget {
  const CustomeBottomNavbar({super.key});

  @override
  State<CustomeBottomNavbar> createState() => _CustomeBottomNavbarState();
}

class _CustomeBottomNavbarState extends State<CustomeBottomNavbar> {
  late final PersistentTabController _controller;
  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Center(
          child: Text(
            'Wallet',
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
            screen: FavoritePage(),
            item: ItemConfig(
              icon: Icon(CupertinoIcons.heart),
              title: "Favorite",
              textStyle: TextStyle(fontWeight: FontWeight.w600),
              activeForegroundColor: AppColors.primaryColor,
              inactiveForegroundColor: AppColors.grey,
            ),
          ),
          PersistentTabConfig(
            screen: GoldWalletPage(),
            item: ItemConfig(
              icon: Icon(CupertinoIcons.gift),
              title: "Wallet",
              textStyle: TextStyle(fontWeight: FontWeight.w600),
              activeForegroundColor: AppColors.primaryColor,
              inactiveForegroundColor: AppColors.grey,
            ),
          ),
        ],
        stateManagement: true,
        navBarBuilder: (navBarConfig) =>
            Style6BottomNavBar(navBarConfig: navBarConfig),
      ),
    );
  }
}
