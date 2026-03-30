import 'package:tpss_ecommerce_gold_wallet/constant/app_release_config.dart';

class AppState {
  final String selectedSeller;

  const AppState({required this.selectedSeller});

  bool get isAllSellers => selectedSeller == AppReleaseConfig.allSellersLabel;

  AppState copyWith({String? selectedSeller}) {
    return AppState(selectedSeller: selectedSeller ?? this.selectedSeller);
  }
}
