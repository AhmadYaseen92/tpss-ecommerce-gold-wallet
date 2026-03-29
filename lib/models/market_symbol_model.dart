class MarketSymbolModel {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final String sellerName;

  const MarketSymbolModel({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.sellerName,
  });

  MarketSymbolModel copyWith({double? price, double? change, String? sellerName}) {
    return MarketSymbolModel(
      symbol: symbol,
      name: name,
      price: price ?? this.price,
      change: change ?? this.change,
      sellerName: sellerName ?? this.sellerName,
    );
  }
}

const List<MarketSymbolModel> initialMarketSymbols = [
  MarketSymbolModel(symbol: 'XAUUSD', name: 'Gold Spot', price: 2189.40, change: 0.42, sellerName: 'Imseeh'),
  MarketSymbolModel(symbol: 'XAGUSD', name: 'Silver Spot', price: 24.66, change: -0.18, sellerName: 'Sakkejha'),
  MarketSymbolModel(symbol: 'XPTUSD', name: 'Platinum Spot', price: 926.35, change: 0.22, sellerName: 'Da’naa'),
  MarketSymbolModel(symbol: 'XPDUSD', name: 'Palladium Spot', price: 1015.20, change: -0.11, sellerName: 'Imseeh'),
  MarketSymbolModel(symbol: 'GCJ26', name: 'Gold Futures (Apr)', price: 2194.80, change: 0.38, sellerName: 'Sakkejha'),
  MarketSymbolModel(symbol: 'SIK26', name: 'Silver Futures (May)', price: 24.89, change: -0.13, sellerName: 'Da’naa'),
];
