class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isFavorite,
    required this.purity,
    required this.weight,
    required this.metal,
    required this.isInCart,
    required this.quantity,
    required this.sellerName,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isFavorite;
  final String purity;
  final String weight;
  final String metal;
  final bool isInCart;
  final int quantity;
  final String sellerName;

  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isFavorite,
    String? purity,
    String? weight,
    String? metal,
    bool? isInCart,
    int? quantity,
    String? sellerName,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      purity: purity ?? this.purity,
      weight: weight ?? this.weight,
      metal: metal ?? this.metal,
      isInCart: isInCart ?? this.isInCart,
      quantity: quantity ?? this.quantity,
      sellerName: sellerName ?? this.sellerName,
    );
  }
}
