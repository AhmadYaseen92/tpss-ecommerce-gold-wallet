import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';

class AppState {
  final String selectedSeller;
  final ThemeMode themeMode;

  const AppState({
    required this.selectedSeller,
    this.themeMode = ThemeMode.system,
  });

  bool get isAllSellers => selectedSeller == AppReleaseConfig.allSellersLabel;

  AppState copyWith({String? selectedSeller, ThemeMode? themeMode}) {
    return AppState(
      selectedSeller: selectedSeller ?? this.selectedSeller,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
