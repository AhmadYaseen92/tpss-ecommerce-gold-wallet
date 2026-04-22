class HomeCarsouleItemModel {
  final String id;
  final String imgUrl;
  final String title;
  final String sellerName;
  final String materialType;
  final String pricingModeLabel;
  final double sourcePrice;
  final double sellPrice;
  final String? offerLabel;

  HomeCarsouleItemModel({
    required this.id,
    required this.imgUrl,
    required this.title,
    required this.sellerName,
    required this.materialType,
    required this.pricingModeLabel,
    required this.sourcePrice,
    required this.sellPrice,
    this.offerLabel,
  });
}
