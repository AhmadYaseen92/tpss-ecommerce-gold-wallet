class ProductCategoryFilter {
  static const List<({String label, int? categoryId})> options = [
    (label: 'Gold', categoryId: 1),
    (label: 'Silver', categoryId: 2),
    (label: 'Diamond', categoryId: 3),
    (label: 'Jewelry', categoryId: 4),
    (label: 'Coins', categoryId: 5),
    (label: 'Spot MR', categoryId: 6),
  ];

  static int inferCategoryId({
    required String name,
    String? description,
  }) {
    final value = '${name.toLowerCase()} ${description?.toLowerCase() ?? ''}';
    if (value.contains('diamond')) return 3;
    if (value.contains('coin')) return 5;
    if (value.contains('jewel') ||
        value.contains('necklace') ||
        value.contains('ring') ||
        value.contains('bracelet')) {
      return 4;
    }
    if (value.contains('spot mr') || value.contains('spot')) return 6;
    if (value.contains('silver')) return 2;
    return 1;
  }
}
