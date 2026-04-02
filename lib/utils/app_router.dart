import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/views/bottom_navbar/page/custom_bottom_navbar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/login/page/login_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/onboarding/page/onboarding_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/page/signup_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/convert/page/convert_page.dart';
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
import 'package:tpss_ecommerce_gold_wallet/views/transfer/page/transfer_gift_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/forgot_password/page/forgot_password_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/splash/page/splash_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/page/confirm_otp_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/page/wallet_actions/sell_asset_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/page/wallet_actions/transfer_asset_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/page/wallet_actions/convert_asset_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/page/wallet_items_page.dart';

import 'package:tpss_ecommerce_gold_wallet/views/account_summary/page/account_summary_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/checkout/page/checkout_payment_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/checkout/page/market_order_checkout_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/page/wallet_actions/generate_tax_invoice_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/page/wallet_actions/pickup_request_page.dart';

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

      case AppRoutes.transferGiftRoute:
        return MaterialPageRoute(builder: (_) => const TransferGiftPage());

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

      case AppRoutes.forgotPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

      case AppRoutes.convertRoute:
        return MaterialPageRoute(builder: (_) => const ConvertPage());

      case AppRoutes.walletItemsRoute:
        final transactions = settings.arguments as List<WalletTransaction>;
        return MaterialPageRoute(
          builder: (_) => WalletItemsPage(transactions: transactions),
        );

      case AppRoutes.walletAssetSellRoute:
        final transaction = settings.arguments as WalletActionSummary;
        return MaterialPageRoute(
          builder: (_) => SellAssetPage(asset: transaction),
        );

      case AppRoutes.walletAssetTransferRoute:
        final transaction = settings.arguments as WalletTransaction;
        return MaterialPageRoute(
          builder: (_) => TransferAssetPage(asset: transaction),
        );

      case AppRoutes.walletAssetConvertRoute:
        final transaction = settings.arguments as WalletTransaction;
        return MaterialPageRoute(
          builder: (_) => ConvertAssetPage(asset: transaction),
        );

      case AppRoutes.walletTaxInvoiceRoute:
        final transaction = settings.arguments as WalletTransaction;
        return MaterialPageRoute(
          builder: (_) => GenerateTaxInvoicePage(asset: transaction),
        );

      case AppRoutes.walletPickupRoute:
        final transaction = settings.arguments as WalletTransaction;
        return MaterialPageRoute(
          builder: (_) => PickupRequestPage(asset: transaction),
        );

      case AppRoutes.accountSummaryRoute:
        return MaterialPageRoute(builder: (_) => const AccountSummaryPage());

      case AppRoutes.checkoutRoute:
        return MaterialPageRoute(builder: (_) => const CheckoutPaymentPage());

      case AppRoutes.marketOrderCheckoutRoute:
        return MaterialPageRoute(builder: (_) => const MarketOrderCheckoutPage(), settings: settings);

      case AppRoutes.confirmOtpRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ConfirmOtpPage(
            title: args?['title'] as String?,
            subtitle: args?['subtitle'] as String?,
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
