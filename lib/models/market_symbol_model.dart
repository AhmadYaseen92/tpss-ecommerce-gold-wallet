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
  MarketSymbolModel(symbol: 'XAU-1OZ', name: 'Gold 1 Oz', price: 2189.40, change: 0.42, sellerName: 'Imseeh'),
  MarketSymbolModel(symbol: 'XAU-100G', name: 'Gold 100 Gram', price: 7041.20, change: 0.33, sellerName: 'Sakkejha'),
  MarketSymbolModel(symbol: 'XAU-1KG', name: 'Gold 1 Kg', price: 70412.50, change: -0.15, sellerName: 'Da’naa'),
  MarketSymbolModel(symbol: 'XAU-10G', name: 'Gold 10 Gram', price: 704.50, change: 0.18, sellerName: 'Imseeh'),
  MarketSymbolModel(symbol: 'XAG-1OZ', name: 'Silver 1 Oz', price: 24.66, change: -0.18, sellerName: 'Sakkejha'),
  MarketSymbolModel(symbol: 'XAG-1KG', name: 'Silver 1 Kg', price: 793.15, change: 0.12, sellerName: 'Da’naa'),
  MarketSymbolModel(symbol: 'XAG-100G', name: 'Silver 100 Gram', price: 79.30, change: -0.09, sellerName: 'Imseeh'),
  MarketSymbolModel(symbol: 'XAG-10G', name: 'Silver 10 Gram', price: 7.93, change: 0.06, sellerName: 'Sakkejha'),
  MarketSymbolModel(symbol: 'GCJ26', name: 'Gold Futures (Apr)', price: 2194.80, change: 0.38, sellerName: 'Sakkejha'),
  MarketSymbolModel(symbol: 'SIK26', name: 'Silver Futures (May)', price: 24.89, change: -0.13, sellerName: 'Da’naa'),
];
