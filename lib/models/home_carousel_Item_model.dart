class HomeCarsouleItemModel {
  final String id;
  final String imgUrl;

  HomeCarsouleItemModel({required this.id, required this.imgUrl});
}

List<HomeCarsouleItemModel> dummyCarsouleItems = [
  HomeCarsouleItemModel(
    id: '1',
    imgUrl:
        'https://c8.alamy.com/comp/2PH5A74/expensive-jewellery-shop-amman-jordan-2PH5A74.jpg',
  ),

  HomeCarsouleItemModel(
    id: '2',
    imgUrl:
        'https://kayalijewelry.com/cdn/shop/files/kayali_banners_1445x.jpg?v=1766574888',
  ),
  HomeCarsouleItemModel(
    id: '3',
    imgUrl:
        'https://www.darjewellery.com/_next/image?url=%2FDar%2FproductDetails%2FHomeBanners%2FMobile%2Fmb5.jpg&w=3840&q=75',
  ),
  HomeCarsouleItemModel(
    id: '4',
    imgUrl:
        'https://imseeh.com/wp-content/uploads/2024/12/main-noelcollection.jpg',
  ),
];
