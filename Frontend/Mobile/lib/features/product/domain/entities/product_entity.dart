class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.price,
    required this.availableStock,
    required this.imageUrl,
    required this.category,
    required this.categoryId,
    required this.isFavorite,
    required this.purity,
    required this.weight,
    required this.metal,
    required this.isInCart,
    required this.quantity,
    required this.sellerName,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final int sellerId;
  final String name;
  final String description;
  final double price;
  final int availableStock;
  final String imageUrl;
  final String category;
  final int categoryId;
  final bool isFavorite;
  final String purity;
  final String weight;
  final String metal;
  final bool isInCart;
  final int quantity;
  final String sellerName;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  ProductEntity copyWith({
    String? id,
    int? sellerId,
    String? name,
    String? description,
    double? price,
    int? availableStock,
    String? imageUrl,
    String? category,
    int? categoryId,
    bool? isFavorite,
    String? purity,
    String? weight,
    String? metal,
    bool? isInCart,
    int? quantity,
    String? sellerName,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      availableStock: availableStock ?? this.availableStock,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
      purity: purity ?? this.purity,
      weight: weight ?? this.weight,
      metal: metal ?? this.metal,
      isInCart: isInCart ?? this.isInCart,
      quantity: quantity ?? this.quantity,
      sellerName: sellerName ?? this.sellerName,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }
}
