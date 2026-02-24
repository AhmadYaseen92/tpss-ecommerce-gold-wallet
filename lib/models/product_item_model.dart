class ProductItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  ProductItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}
//dummy product list data , bullion and jewellery

List<ProductItemModel> dummyProducts = [
  ProductItemModel(
    id: '1',
    name: 'Gold Bullion',
    description: '24K pure gold bullion for investment.',
    price: 1500.00,
    imageUrl:
        'https://product-img-prod-goldcore.s3.amazonaws.com/673fb3120835f693923313.webp',
  ),
  ProductItemModel(
    id: '2',
    name: 'Silver Bullion',
    description: 'High-quality silver bullion for collectors.',
    price: 25.00,
    imageUrl:
        'https://product-img-prod-goldcore.s3.amazonaws.com/673fb3120835f693923313.webp',
  ),
  ProductItemModel(
    id: '3',
    name: 'Diamond Necklace',
    description: 'Elegant diamond necklace for special occasions.',
    price: 5000.00,
    imageUrl:
        'https://product-img-prod-goldcore.s3.amazonaws.com/673fb3120835f693923313.webp',
  ),
  ProductItemModel(
    id: '4',
    name: 'Platinum Ring',
    description: 'Stylish platinum ring for everyday wear.',
    price: 1200.00,
    imageUrl:
        'https://product-img-prod-goldcore.s3.amazonaws.com/673fb3120835f693923313.webp',
  ),
];
