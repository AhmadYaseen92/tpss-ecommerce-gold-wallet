class HomeCarsouleItemModel {
  final String id;
  final String imgUrl;
  final String title;
  final String sellerName;
  final String? offerLabel;

  HomeCarsouleItemModel({
    required this.id,
    required this.imgUrl,
    required this.title,
    required this.sellerName,
    this.offerLabel,
  });
}

List<HomeCarsouleItemModel> dummyCarsouleItems = [
  HomeCarsouleItemModel(
    id: '1',
    imgUrl:
        'https://urdu.bharatexpress.com/wp-content/uploads/2025/12/collage-67.webp',
    title: 'Gold Bar 10g',
    sellerName: 'Featured Seller',
    offerLabel: 'Offer 10% OFF',
  ),

  HomeCarsouleItemModel(
    id: '2',
    imgUrl:
        'https://nygoldco.com/wp-content/uploads/2026/01/Exchange-Old-Jewellery-For-24k-Gold-Silver-Bar-NYGOLD-Banner-2.jpg',
    title: 'Premium Gold Coins',
    sellerName: 'Featured Seller',
    offerLabel: 'Limited Offer',
  ),
  HomeCarsouleItemModel(
    id: '3',
    imgUrl:
        'https://www.goldmarket.fr/wp-content/uploads/2025/09/84fbec39thumbnail-1110x550.jpeg.webp',
    title: 'Jewelry Collection',
    sellerName: 'Featured Seller',
    offerLabel: null,
  ),
  HomeCarsouleItemModel(
    id: '4',
    imgUrl:
        'https://summitmetals.com/cdn/shop/articles/4ce621b98e385ee578e60830620883bccafe5f44.jpg?v=1773745763',
    title: 'Silver Investment Picks',
    sellerName: 'Featured Seller',
    offerLabel: null,
  ),
];
