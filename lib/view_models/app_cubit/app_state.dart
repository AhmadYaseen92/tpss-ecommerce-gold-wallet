class AppState {
  final String selectedSeller;

  const AppState({required this.selectedSeller});

  bool get isAllSellers => selectedSeller == 'All Sellers';

  AppState copyWith({String? selectedSeller}) {
    return AppState(selectedSeller: selectedSeller ?? this.selectedSeller);
  }
}
