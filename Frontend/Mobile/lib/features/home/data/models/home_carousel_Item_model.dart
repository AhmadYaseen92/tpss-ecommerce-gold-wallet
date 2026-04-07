class HomeCarsouleItemModel {
  final String id;
  final String imgUrl;

  HomeCarsouleItemModel({required this.id, required this.imgUrl});
}

List<HomeCarsouleItemModel> dummyCarsouleItems = [
  HomeCarsouleItemModel(
    id: '1',
    imgUrl:
        'https://urdu.bharatexpress.com/wp-content/uploads/2025/12/collage-67.webp',
  ),

  HomeCarsouleItemModel(
    id: '2',
    imgUrl:
        'https://nygoldco.com/wp-content/uploads/2026/01/Exchange-Old-Jewellery-For-24k-Gold-Silver-Bar-NYGOLD-Banner-2.jpg',
  ),
  HomeCarsouleItemModel(
    id: '3',
    imgUrl:
        'https://www.goldmarket.fr/wp-content/uploads/2025/09/84fbec39thumbnail-1110x550.jpeg.webp',
  ),
  HomeCarsouleItemModel(
    id: '4',
    imgUrl:
        'https://summitmetals.com/cdn/shop/articles/4ce621b98e385ee578e60830620883bccafe5f44.jpg?v=1773745763',
  ),
];
