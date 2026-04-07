class MarketSymbolEntity {
  const MarketSymbolEntity({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.sellerName,
  });

  final String symbol;
  final String name;
  final double price;
  final double change;
  final String sellerName;
}
