class ProductItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isFavorite; // Added favorite state

  ProductItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isFavorite = false,
  });

  ProductItemModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isFavorite,
  }) {
    return ProductItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
//dummy product list data , bullion and jewellery

List<ProductItemModel> dummyProducts = [
  ProductItemModel(
    id: '1',
    name: 'Gold Bar 1 oz',
    description: '24k • 999.9 Purity',
    price: 1950.00,
    imageUrl:
        'https://bfasset.costco-static.com/U447IH35/as/9tnb5fqxj5gtkn5sg8jrh/4000364603-894__1?auto=webp&amp;format=jpg&width=600&height=600&fit=bounds&canvas=600,600',
    category: 'Bullion',
  ),
  ProductItemModel(
    id: '2',
    name: 'Gold Bar 10 g',
    description: '24k • 999.9 Purity',
    price: 620.00,
    imageUrl: 'https://www.pamp.com/sites/pamp/files/2022-02/10g_1.png',
    category: 'Bullion',
  ),
  ProductItemModel(
    id: '3',
    name: 'Silver Bar 1 oz',
    description: '999.0 • Bullion',
    price: 25.50,
    imageUrl:
        'https://www.pamp.com/sites/pamp/files/2024-10/pamp-1oz-silver-bar-usa-webimage-1000x1000px-obv.png',
    category: 'Bullion',
  ),
  ProductItemModel(
    id: '4',
    name: 'Silver Round 1 oz',
    description: '999.0 • Bullion',
    price: 26.00,
    imageUrl:
        'https://static.jmbullion.com/image/upload/q_auto,f_auto,w_202,h_202/v1761337031/SRSUNMERCURY1_4_obverse',
    category: 'Coins',
  ),
  ProductItemModel(
    id: '5',
    name: 'Gold Sovereign Coin',
    description: '22k • Bullion Coin',
    price: 420.00,
    imageUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMuutlptbB5vglIH1XrZZaI8nRKwO_Z_zr3g&s',
    category: 'Coins',
  ),
  ProductItemModel(
    id: '6',
    name: 'Platinum Bar 1 oz',
    description: 'Platinum • Bullion',
    price: 950.00,
    imageUrl:
        'https://www.pamp.com/sites/pamp/files/2022-02/1oz_platinum_sfondo_lucido_obv.png',
    category: 'Bullion',
  ),
  ProductItemModel(
    id: '7',
    name: 'Palladium Bar 1 oz',
    description: 'Palladium • Bullion',
    price: 2100.00,
    imageUrl:
        'https://www.indigopreciousmetals.com/media/catalog/product/cache/1/main/450x450/9df78eab33525d08d6e5fb8d27136e95/s/c/screenshot_2023-02-09_at_5.29.34_pm-removebg-preview.png',
    category: 'Bullion',
  ),
  ProductItemModel(
    id: '8',
    name: 'Gold Cast Bar 100 g',
    description: '24k • 100 g',
    price: 6200.00,
    imageUrl:
        'https://res.cloudinary.com/duk8bjkwn/image/upload/v1670842538/arjrzytvyxkfnaqfntbu.png',
    category: 'Bullion',
  ),
  ProductItemModel(
    id: '9',
    name: 'Diamond Solitaire Ring',
    description: '1.0 ct • 18K',
    price: 8500.00,
    imageUrl:
        'https://www.serendipitydiamonds.com/blog/wp-content/uploads/2021/11/kensington-engagement-ring-side-view.jpg',
    category: 'Jewellery',
  ),
  ProductItemModel(
    id: '10',
    name: 'Gold Necklace 18K',
    description: '18k • Premium',
    price: 1200.00,
    imageUrl:
        'https://www.baublebar.com/cdn/shop/files/64317_G_01.jpg?v=1746637318&width=1512',
    category: 'Jewellery',
  ),
  ProductItemModel(
    id: '11',
    name: 'Pearl Strand Necklace',
    description: 'Cultured • Premium',
    price: 750.00,
    imageUrl:
        'https://www.simoncurwood.com.au/cdn/shop/files/169504_3-2.jpg?v=1699504242&width=713',
    category: 'Jewellery',
  ),
  ProductItemModel(
    id: '12',
    name: 'Sapphire Pendant',
    description: 'Blue Sapphire • 18K',
    price: 1100.00,
    imageUrl:
        'https://www.garrard.com/cdn/shop/files/Garrard-1735-jewellery-collection-Sapphire-Double-Cluster-Pendant-in-Platinum-with-Diamonds-JP17PT11-Hero-View.png?v=1755187464&width=1200',
    category: 'Jewellery',
  ),
  ProductItemModel(
    id: '13',
    name: 'Platinum Wedding Band',
    description: 'Platinum • Comfort Fit',
    price: 980.00,
    imageUrl:
        'https://cdn11.bigcommerce.com/s-9b8niz/images/stencil/1100w/products/5478/27911/hammered-950-platinum-wedding-band__18289.1764670069.jpg?c=2',
    category: 'Jewellery',
  ),
  ProductItemModel(
    id: '14',
    name: 'Gold Hoop Earrings',
    description: '14k • Premium',
    price: 320.00,
    imageUrl:
        'https://img01.ztat.net/article/spp-media-p1/222bfc5d7d1b496f8c3a3dcbd176614e/5ea201ae03b141e3bf485e7129cc63d8.jpg?imwidth=1800',
    category: 'Jewellery',
  ),
  ProductItemModel(
    id: '15',
    name: 'Emerald Cocktail Ring',
    description: 'Emerald • Diamond Halo',
    price: 2600.00,
    imageUrl:
        'https://glennbradford.com/cdn/shop/products/EmeraldAndDiamondRing-singleweb_540x.jpg?v=1616012868',
    category: 'Jewellery',
  ),
];
