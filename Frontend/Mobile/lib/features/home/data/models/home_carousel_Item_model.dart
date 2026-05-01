class HomeCarsouleItemModel {
  final String id;
  final String imgUrl;
  final String title;
  final String sellerName;
  final String materialType;
  final String pricingModeLabel;
  final String currencyCode;
  final double sourcePrice;
  final double askPrice;
  final String? offerLabel;

  HomeCarsouleItemModel({
    required this.id,
    required this.imgUrl,
    required this.title,
    required this.sellerName,
    required this.materialType,
    required this.pricingModeLabel,
    required this.currencyCode,
    required this.sourcePrice,
    required this.askPrice,
    this.offerLabel,
  });
}
