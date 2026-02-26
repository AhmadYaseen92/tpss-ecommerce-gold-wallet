class ProductItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isFavorite; // Added favorite state
  final String purity;
  final String weight;
  final String metal;

  ProductItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isFavorite = false,
    this.purity = '',
    this.weight = '',
    this.metal = '',
  });

  ProductItemModel copyWith({
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
  }) {
    return ProductItemModel(
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
    );
  }
}
//dummy product list data , bullion and jewellery

List<ProductItemModel> dummyProducts = [
  ProductItemModel(
    id: '1',
    name: 'Gold Bar 1 oz',
    description:
        'This 1 ounce gold bar is made from pure 24-karat gold with an exceptional 999.9 purity level. It is globally recognized and highly liquid, making it a reliable choice for investors seeking long-term wealth preservation and physical ownership of precious metals.',
    price: 1950.00,
    imageUrl:
        'https://bfasset.costco-static.com/U447IH35/as/9tnb5fqxj5gtkn5sg8jrh/4000364603-894__1?auto=webp&format=jpg&width=600&height=600&fit=bounds&canvas=600,600',
    category: 'Bullion',
    purity: '24k',
    weight: '1 oz',
    metal: 'Gold',
  ),

  ProductItemModel(
    id: '2',
    name: 'Gold Bar 10 g',
    description:
        'The 10 gram gold bar offers an accessible entry into gold investment while maintaining premium quality. Crafted from 24-karat gold with 999.9 purity, it is ideal for saving, gifting, or gradually building a diversified precious metals portfolio.',
    price: 620.00,
    imageUrl: 'https://www.pamp.com/sites/pamp/files/2022-02/10g_1.png',
    category: 'Bullion',
    purity: '24k',
    weight: '10 g',
    metal: 'Gold',
  ),

  ProductItemModel(
    id: '3',
    name: 'Silver Bar 1 oz',
    description:
        'This 1 ounce silver bar is refined to a purity of 999.0 fine silver, ensuring high quality and authenticity. It is a popular choice among investors due to its affordability, ease of storage, and strong industrial and investment demand.',
    price: 25.50,
    imageUrl:
        'https://www.pamp.com/sites/pamp/files/2024-10/pamp-1oz-silver-bar-usa-webimage-1000x1000px-obv.png',
    category: 'Bullion',
    purity: '999.0',
    weight: '1 oz',
    metal: 'Silver',
  ),

  ProductItemModel(
    id: '4',
    name: 'Silver Round 1 oz',
    description:
        'This silver round contains one ounce of 999.0 fine silver and is produced specifically for bullion investment. Unlike circulating coins, it is valued mainly for its silver content, making it a cost-effective and practical option for silver stacking.',
    price: 26.00,
    imageUrl:
        'https://static.jmbullion.com/image/upload/q_auto,f_auto,w_202,h_202/v1761337031/SRSUNMERCURY1_4_obverse',
    category: 'Coins',
    purity: '999.0',
    weight: '1 oz',
    metal: 'Silver',
  ),

  ProductItemModel(
    id: '5',
    name: 'Gold Sovereign Coin',
    description:
        'The gold sovereign coin is struck from durable 22-karat gold and is known for its historical significance and strong bullion value. Widely recognized and trusted, it offers excellent liquidity and long-term appeal for both collectors and investors.',
    price: 420.00,
    imageUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMuutlptbB5vglIH1XrZZaI8nRKwO_Z_zr3g&s',
    category: 'Coins',
    purity: '22k',
    weight: '1 oz',
    metal: 'Gold',
  ),

  ProductItemModel(
    id: '6',
    name: 'Platinum Bar 1 oz',
    description:
        'This 1 ounce platinum bar is refined to 999.0 purity, offering exposure to one of the rarest precious metals. Platinum is valued for its limited supply and industrial use, making this bar an excellent diversification asset beyond gold and silver.',
    price: 950.00,
    imageUrl:
        'https://www.pamp.com/sites/pamp/files/2022-02/1oz_platinum_sfondo_lucido_obv.png',
    category: 'Bullion',
    purity: '999.0',
    weight: '1 oz',
    metal: 'Platinum',
  ),

  ProductItemModel(
    id: '7',
    name: 'Palladium Bar 1 oz',
    description:
        'The palladium bar contains one ounce of 999.0 fine palladium, a rare metal widely used in automotive and industrial applications. Its limited global supply and growing demand make it a unique and strategic precious metal investment.',
    price: 2100.00,
    imageUrl:
        'https://www.indigopreciousmetals.com/media/catalog/product/cache/1/main/450x450/9df78eab33525d08d6e5fb8d27136e95/s/c/screenshot_2023-02-09_at_5.29.34_pm-removebg-preview.png',
    category: 'Bullion',
    purity: '999.0',
    weight: '1 oz',
    metal: 'Palladium',
  ),

  ProductItemModel(
    id: '8',
    name: 'Gold Cast Bar 100 g',
    description:
        'This 100 gram gold cast bar is made from solid 24-karat gold with 999.9 purity and features a traditional cast finish. Designed for serious investors, it offers excellent value per gram and secure long-term wealth storage.',
    price: 6200.00,
    imageUrl:
        'https://res.cloudinary.com/duk8bjkwn/image/upload/v1670842538/arjrzytvyxkfnaqfntbu.png',
    category: 'Bullion',
    purity: '24k',
    weight: '100 g',
    metal: 'Gold',
  ),

  ProductItemModel(
    id: '9',
    name: 'Diamond Solitaire Ring',
    description:
        'This elegant solitaire ring features a brilliant 1.0 carat diamond set in premium 18-karat gold. Designed to highlight the diamond’s clarity and sparkle, it is a timeless jewellery piece ideal for engagements and special occasions.',
    price: 8500.00,
    imageUrl:
        'https://www.serendipitydiamonds.com/blog/wp-content/uploads/2021/11/kensington-engagement-ring-side-view.jpg',
    category: 'Jewellery',
    purity: '18k',
    weight: '1.0 ct',
    metal: 'Gold',
  ),

  ProductItemModel(
    id: '10',
    name: 'Gold Necklace 18K',
    description:
        'This 18-karat gold necklace combines refined craftsmanship with everyday durability. Its classic design makes it suitable for both daily wear and special events, adding elegance and lasting value to any jewellery collection.',
    price: 1200.00,
    imageUrl:
        'https://www.baublebar.com/cdn/shop/files/64317_G_01.jpg?v=1746637318&width=1512',
    category: 'Jewellery',
    purity: '18k',
    weight: '1 oz',
    metal: 'Gold',
  ),

  ProductItemModel(
    id: '11',
    name: 'Pearl Strand Necklace',
    description:
        'This pearl strand necklace features carefully selected cultured pearls paired with a premium gold clasp. Known for its timeless beauty and elegance, it complements both formal and casual outfits with classic sophistication.',
    price: 750.00,
    imageUrl:
        'https://www.simoncurwood.com.au/cdn/shop/files/169504_3-2.jpg?v=1699504242&width=713',
    category: 'Jewellery',
    purity: '18k',
    weight: '1 oz',
    metal: 'Gold',
  ),

  ProductItemModel(
    id: '12',
    name: 'Sapphire Pendant',
    description:
        'This sapphire pendant showcases a deep blue sapphire set in elegant 18-karat gold. Sapphire is valued for its durability and symbolism of wisdom and loyalty, making this pendant both meaningful and visually striking.',
    price: 1100.00,
    imageUrl:
        'https://www.garrard.com/cdn/shop/files/Garrard-1735-jewellery-collection-Sapphire-Double-Cluster-Pendant-in-Platinum-with-Diamonds-JP17PT11-Hero-View.png?v=1755187464&width=1200',
    category: 'Jewellery',
    purity: '18k',
    weight: '1 oz',
    metal: 'Gold',
  ),

  ProductItemModel(
    id: '13',
    name: 'Platinum Wedding Band',
    description:
        'This platinum wedding band is designed with a comfort-fit interior for daily wear. Platinum’s exceptional durability and natural white luster make it a perfect symbol of lasting commitment and lifelong partnership.',
    price: 980.00,
    imageUrl:
        'https://cdn11.bigcommerce.com/s-9b8niz/images/stencil/1100w/products/5478/27911/hammered-950-platinum-wedding-band__18289.1764670069.jpg?c=2',
    category: 'Jewellery',
    purity: '18k',
    weight: '1 oz',
    metal: 'Gold',
  ),

  ProductItemModel(
    id: '14',
    name: 'Gold Hoop Earrings',
    description:
        'These gold hoop earrings are crafted from high-quality 14-karat gold, offering a perfect balance of durability and style. Lightweight and versatile, they are suitable for daily wear or elegant occasions.',
    price: 320.00,
    imageUrl:
        'https://img01.ztat.net/article/spp-media-p1/222bfc5d7d1b496f8c3a3dcbd176614e/5ea201ae03b141e3bf485e7129cc63d8.jpg?imwidth=1800',
    category: 'Jewellery',
    purity: '18k',
    weight: '1 oz',
    metal: 'Gold',
  ),

  ProductItemModel(
    id: '15',
    name: 'Emerald Cocktail Ring',
    description:
        'This emerald cocktail ring features a vivid green emerald surrounded by a sparkling diamond halo. Designed to stand out, it combines luxury and elegance, making it ideal for formal events and statement jewellery collections.',
    price: 2600.00,
    imageUrl:
        'https://glennbradford.com/cdn/shop/products/EmeraldAndDiamondRing-singleweb_540x.jpg?v=1616012868',
    category: 'Jewellery',
    purity: '18k',
    weight: '1 oz',
    metal: 'Emerald',
  ),
];