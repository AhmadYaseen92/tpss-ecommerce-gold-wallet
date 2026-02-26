import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/views/bottom_navbar/page/custom_bottom_navbar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product_details/page/product_detail_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.homeRoute:
        return MaterialPageRoute(builder: (_) => const CustomeBottomNavbar());

      case AppRoutes.productDetailsRoute:
        return MaterialPageRoute(
          builder: (_) => ProductDetailPage(
            product: settings.arguments as ProductItemModel,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
