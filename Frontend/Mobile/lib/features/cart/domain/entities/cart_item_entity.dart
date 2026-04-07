class CartItemEntity {
  const CartItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.sellerName,
    required this.quantity,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String sellerName;
  final int quantity;

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      sellerName: sellerName,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartSummaryEntity {
  const CartSummaryEntity({
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  final double subtotal;
  final double tax;
  final double total;
}
