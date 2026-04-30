import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';

class AppState {
  final String selectedSeller;
  final ThemeMode themeMode;
  final Locale? locale;
  final int checkoutRefreshTick;

  const AppState({
    required this.selectedSeller,
    this.themeMode = ThemeMode.system,
    this.locale,
    this.checkoutRefreshTick = 0,
  });

  bool get isAllSellers => selectedSeller == AppReleaseConfig.allSellersLabel;

  AppState copyWith({
    String? selectedSeller,
    ThemeMode? themeMode,
    Locale? locale,
    bool clearLocale = false,
    int? checkoutRefreshTick,
  }) {
    return AppState(
      selectedSeller: selectedSeller ?? this.selectedSeller,
      themeMode: themeMode ?? this.themeMode,
      locale: clearLocale ? null : (locale ?? this.locale),
      checkoutRefreshTick: checkoutRefreshTick ?? this.checkoutRefreshTick,
    );
  }
}
