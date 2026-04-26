class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.baseMarketPrice,
    required this.autoPrice,
    required this.fixedPrice,
    required this.sellPrice,
    required this.availableStock,
    required this.imageUrl,
    required this.category,
    required this.categoryId,
    required this.isFavorite,
    required this.purity,
    required this.weight,
    required this.materialTypeLabel,
    required this.productFormLabel,
    required this.isInCart,
    required this.quantity,
    required this.sellerName,
    required this.offerType,
    required this.offerPercent,
    required this.offerNewPrice,
    required this.isHasOffer,
    required this.pricingModeLabel,
  });

  final String id;
  final int sellerId;
  final String name;
  final String description;
  final double baseMarketPrice;
  final double autoPrice;
  final double fixedPrice;
  final double sellPrice;
  final int availableStock;
  final String imageUrl;
  final String category;
  final int categoryId;
  final bool isFavorite;
  final String purity;
  final String weight;
  final String materialTypeLabel;
  final String productFormLabel;
  final bool isInCart;
  final int quantity;
  final String sellerName;
  final String offerType;
  final double offerPercent;
  final double offerNewPrice;
  final bool isHasOffer;
  final String pricingModeLabel;

  ProductEntity copyWith({
    String? id,
    int? sellerId,
    String? name,
    String? description,
    double? baseMarketPrice,
    double? autoPrice,
    double? fixedPrice,
    double? sellPrice,
    int? availableStock,
    String? imageUrl,
    String? category,
    int? categoryId,
    bool? isFavorite,
    String? purity,
    String? weight,
    String? materialTypeLabel,
    String? productFormLabel,
    bool? isInCart,
    int? quantity,
    String? sellerName,
    String? offerType,
    double? offerPercent,
    double? offerNewPrice,
    bool? isHasOffer,
    String? pricingModeLabel,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      description: description ?? this.description,
      baseMarketPrice: baseMarketPrice ?? this.baseMarketPrice,
      autoPrice: autoPrice ?? this.autoPrice,
      fixedPrice: fixedPrice ?? this.fixedPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      availableStock: availableStock ?? this.availableStock,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
      purity: purity ?? this.purity,
      weight: weight ?? this.weight,
      materialTypeLabel: materialTypeLabel ?? this.materialTypeLabel,
      productFormLabel: productFormLabel ?? this.productFormLabel,
      isInCart: isInCart ?? this.isInCart,
      quantity: quantity ?? this.quantity,
      sellerName: sellerName ?? this.sellerName,
      offerType: offerType ?? this.offerType,
      offerPercent: offerPercent ?? this.offerPercent,
      offerNewPrice: offerNewPrice ?? this.offerNewPrice,
      isHasOffer: isHasOffer ?? this.isHasOffer,
      pricingModeLabel: pricingModeLabel ?? this.pricingModeLabel,
    );
  }
}
