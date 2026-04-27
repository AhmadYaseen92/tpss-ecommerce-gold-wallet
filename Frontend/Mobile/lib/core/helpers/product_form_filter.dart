class ProductFormFilter {
  static const String all = 'All';
  static const String jewelry = 'Jewelry';

  static const List<String> _goldAndSilverForms = ['All', 'Jewelry', 'Coin', 'Bar'];
  static const List<String> _diamondFormsOnly = ['Jewelry'];

  static List<String> optionsForCategory(int? categoryId) {
    if (categoryId == 3) return _diamondFormsOnly;
    return _goldAndSilverForms;
  }

  static String defaultForCategory(int? categoryId) {
    if (categoryId == 3) return jewelry;
    return all;
  }

  static bool matches({
    required String selectedForm,
    required String productFormLabel,
  }) {
    if (selectedForm == all) return true;
    return productFormLabel.trim().toLowerCase() == selectedForm.trim().toLowerCase();
  }
}
