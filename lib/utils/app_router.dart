import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/views/bottom_navbar/page/custom_bottom_navbar.dart';

import 'package:tpss_ecommerce_gold_wallet/views/login/page/login_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/onboarding/page/onboarding_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/page/signup_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/convert/page/convert_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/login/page/login_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/notification/page/notification_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product/page/product_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product_details/page/product_detail_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/pages/language_settings_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/pages/linked_bank_accounts_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/pages/payment_methods_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/pages/personal_information_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/pages/profile_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/pages/security_settings_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/pages/theme_settings_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/sell/page/sell_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/page/signup_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/splash/page/splash_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case AppRoutes.onboardingRoute:
        return MaterialPageRoute(builder: (_) => OnboardingPage());

      case AppRoutes.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.signupRoute:
        return MaterialPageRoute(builder: (_) => const SignupPage());

      case AppRoutes.homeRoute:
        return MaterialPageRoute(builder: (_) => const CustomeBottomNavbar());

      case AppRoutes.productDetailsRoute:
        return MaterialPageRoute(
          builder: (_) => ProductDetailPage(
            product: settings.arguments as ProductItemModel,
          ),
        );

      case AppRoutes.productRoute:
        return MaterialPageRoute(builder: (_) => const ProductPage());

      case AppRoutes.sellRoute:
        return MaterialPageRoute(builder: (_) => const SellGoldPage());

      case AppRoutes.notificationRoute:
        return MaterialPageRoute(builder: (_) => const NotificationPage());

      case AppRoutes.profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case AppRoutes.personalInformationRoute:
        return MaterialPageRoute(
          builder: (_) => const PersonalInformationPage(),
        );

      case AppRoutes.securitySettingsRoute:
        return MaterialPageRoute(builder: (_) => const SecuritySettingsPage());

      case AppRoutes.linkedBankAccountsRoute:
        return MaterialPageRoute(
          builder: (_) => const LinkedBankAccountsPage(),
        );

      case AppRoutes.paymentMethodsRoute:
        return MaterialPageRoute(builder: (_) => const PaymentMethodsPage());

      case AppRoutes.languageRoute:
        return MaterialPageRoute(builder: (_) => const LanguageSettingsPage());

      case AppRoutes.themeRoute:
        return MaterialPageRoute(builder: (_) => const ThemeSettingsPage());

      case AppRoutes.convertRoute:
        return MaterialPageRoute(builder: (_) => const ConvertPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
