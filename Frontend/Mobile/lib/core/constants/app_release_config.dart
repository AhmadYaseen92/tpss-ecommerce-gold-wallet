import 'package:flutter/foundation.dart';

class AppReleaseConfig {
  static final Map<String, dynamic> _allTypedConfig = <String, dynamic>{};
  static final ValueNotifier<int> revisionListenable = ValueNotifier<int>(0);

  static bool isIndividualSellerRelease = false;
  static String individualSellerName = 'Imseeh';

  static const String defaultAllSellersLabel = 'All Sellers';
  static const String allSellersLabel = defaultAllSellersLabel;

  static bool showWeightInGrams = true;
  static bool marketWatchEnabled = true;
  static bool myAccountSummaryEnabled = true;
  static bool loginByBiometricEnabled = true;
  static bool loginByPinEnabled = true;
  static bool get quickUnlockAllowed => loginByBiometricEnabled || loginByPinEnabled;
  static const List<String> _defaultOtpRequiredActions = <String>[
    'registration',
    'reset_password',
    'checkout',
    'buy',
    'sell',
    'transfer',
    'gift',
    'pickup',
    'add_bank_account',
    'edit_bank_account',
    'remove_bank_account',
    'add_payment_method',
    'edit_payment_method',
    'remove_payment_method',
    'change_email',
    'change_password',
    'change_mobile_number',
  ];

  static bool get showSellerUi => !isIndividualSellerRelease;

  static String get defaultSeller =>
      isIndividualSellerRelease ? individualSellerName : allSellersLabel;

  static bool matchesSeller(String activeSeller, String itemSeller) {
    if (isIndividualSellerRelease) {
      return itemSeller == individualSellerName;
    }
    return activeSeller == allSellersLabel || itemSeller == activeSeller;
  }

  static bool get otpEnabled =>
      ((getValue('Otp_EnableWhatsapp') as bool?) ?? true) ||
      ((getValue('Otp_EnableEmail') as bool?) ?? true);

  static List<String> get otpRequiredActions {
    final raw = getValue('Otp_RequiredActions');
    if (raw is String && raw.trim().isNotEmpty) {
      return raw
          .split(',')
          .map((x) => x.trim().toLowerCase())
          .where((x) => x.isNotEmpty)
          .toSet()
          .toList();
    }
    return List<String>.from(_defaultOtpRequiredActions);
  }

  static bool isOtpRequiredForAction(String actionType) {
    final normalized = actionType.trim().toLowerCase();
    if (normalized.isEmpty || !otpEnabled) return false;
    return otpRequiredActions.contains(normalized);
  }

  static void applyFromTypedConfig(Map<String, dynamic> values) {
    final nextIndividualSellerRelease =
        (values['MobileRelease_IsIndividualSeller'] as bool?) ?? isIndividualSellerRelease;
    final nextIndividualSellerName =
        (values['MobileRelease_IndividualSellerName'] as String?) ?? individualSellerName;
    final nextShowWeightInGrams =
        (values['MobileRelease_ShowWeightInGrams'] as bool?) ?? showWeightInGrams;
    final nextMarketWatchEnabled =
        (values['MobileRelease_MarketWatchEnabled'] as bool?) ?? marketWatchEnabled;
    final nextMyAccountSummaryEnabled =
        (values['MobileRelease_MyAccountSummaryEnabled'] as bool?) ?? myAccountSummaryEnabled;
    final nextLoginByBiometricEnabled =
        (values['MobileSecurity_LoginByBiometric'] as bool?) ?? loginByBiometricEnabled;
    final nextLoginByPinEnabled =
        (values['MobileSecurity_LoginByPin'] as bool?) ?? loginByPinEnabled;

    final hasChanged = nextIndividualSellerRelease != isIndividualSellerRelease ||
        nextIndividualSellerName != individualSellerName ||
        nextShowWeightInGrams != showWeightInGrams ||
        nextMarketWatchEnabled != marketWatchEnabled ||
        nextMyAccountSummaryEnabled != myAccountSummaryEnabled ||
        nextLoginByBiometricEnabled != loginByBiometricEnabled ||
        nextLoginByPinEnabled != loginByPinEnabled;

    _allTypedConfig
      ..clear()
      ..addAll(values);

    isIndividualSellerRelease = nextIndividualSellerRelease;
    individualSellerName = nextIndividualSellerName;
    showWeightInGrams = nextShowWeightInGrams;
    marketWatchEnabled = nextMarketWatchEnabled;
    myAccountSummaryEnabled = nextMyAccountSummaryEnabled;
    loginByBiometricEnabled = nextLoginByBiometricEnabled;
    loginByPinEnabled = nextLoginByPinEnabled;

    if (hasChanged) {
      revisionListenable.value = revisionListenable.value + 1;
    }
  }

  static dynamic getValue(String key) => _allTypedConfig[key];
}
