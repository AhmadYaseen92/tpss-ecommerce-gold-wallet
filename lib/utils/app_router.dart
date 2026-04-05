import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/navigation/presentation/pages/custom_bottom_navbar.dart';
import 'package:tpss_ecommerce_gold_wallet/features/login/presentation/pages/login_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/signup/presentation/pages/signup_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/convert/presentation/pages/convert_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/notification/presentation/pages/notification_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/pages/product_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product_details/presentation/pages/product_detail_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/pages/language_settings_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/pages/linked_bank_accounts_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/pages/payment_methods_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/pages/personal_information_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/pages/profile_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/pages/security_settings_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/pages/theme_settings_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/presentation/pages/sell_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/presentation/pages/transfer_gift_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/forgot_password/presentation/pages/forgot_password_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/splash/presentation/pages/splash_page.dart';
import 'package:tpss_ecommerce_gold_wallet/core/pages/confirm_otp_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/pages/wallet_actions/sell_asset_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/pages/wallet_actions/transfer_asset_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/pages/wallet_actions/convert_asset_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/pages/wallet_items_page.dart';

import 'package:tpss_ecommerce_gold_wallet/features/account_summary/presentation/pages/account_summary_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/presentation/pages/checkout_payment_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/presentation/pages/market_order_checkout_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/market_orders/presentation/pages/market_order_list_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/pages/wallet_actions/generate_tax_invoice_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/pages/wallet_actions/pickup_request_page.dart';

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

      case AppRoutes.marketOrderListRoute:
        return MaterialPageRoute(builder: (_) => const MarketOrderListPage());

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
