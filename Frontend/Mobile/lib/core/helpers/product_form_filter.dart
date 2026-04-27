class ProductFormFilter {
  static const String all = 'All';

  static const List<String> _goldAndSilverForms = ['All', 'Jewelry', 'Coin', 'Bar'];
  static const List<String> _diamondForms = ['All', 'Jewelry'];

  static List<String> optionsForCategory(int? categoryId) {
    if (categoryId == 3) return _diamondForms;
    return _goldAndSilverForms;
  }

  static bool matches({
    required String selectedForm,
    required String productFormLabel,
  }) {
    if (selectedForm == all) return true;
    return productFormLabel.trim().toLowerCase() == selectedForm.trim().toLowerCase();
  }
}
