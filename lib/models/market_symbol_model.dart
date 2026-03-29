class MarketSymbolModel {
  final String symbol;
  final String name;
  final double price;
  final double change;

  const MarketSymbolModel({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
  });

  MarketSymbolModel copyWith({double? price, double? change}) {
    return MarketSymbolModel(
      symbol: symbol,
      name: name,
      price: price ?? this.price,
      change: change ?? this.change,
    );
  }
}

const List<MarketSymbolModel> initialMarketSymbols = [
  MarketSymbolModel(symbol: 'XAUUSD', name: 'Gold Spot', price: 2189.40, change: 0.42),
  MarketSymbolModel(symbol: 'XAGUSD', name: 'Silver Spot', price: 24.66, change: -0.18),
  MarketSymbolModel(symbol: 'XPTUSD', name: 'Platinum Spot', price: 926.35, change: 0.22),
  MarketSymbolModel(symbol: 'XPDUSD', name: 'Palladium Spot', price: 1015.20, change: -0.11),
  MarketSymbolModel(symbol: 'GCJ26', name: 'Gold Futures (Apr)', price: 2194.80, change: 0.38),
  MarketSymbolModel(symbol: 'SIK26', name: 'Silver Futures (May)', price: 24.89, change: -0.13),
];
