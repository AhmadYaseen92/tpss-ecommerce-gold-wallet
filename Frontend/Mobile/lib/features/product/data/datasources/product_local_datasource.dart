import 'dart:async';
import 'dart:math';

import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/data/models/market_symbol_model.dart';

class ProductLocalDataSource {
  List<MarketSymbolModel> _symbols = List<MarketSymbolModel>.from(initialMarketSymbols);

  final StreamController<List<MarketSymbolModel>> _symbolController =
      StreamController<List<MarketSymbolModel>>.broadcast();
  Timer? _marketTimer;

  Stream<List<MarketSymbolModel>> watchMarketSymbols() {
    _startFeedIfNeeded();
    _symbolController.add(List<MarketSymbolModel>.from(_symbols));
    return _symbolController.stream;
  }

  void dispose() {
    _marketTimer?.cancel();
    _symbolController.close();
  }

  void _startFeedIfNeeded() {
    if (_marketTimer != null) return;
    if (!AppReleaseConfig.enablePollingFallback) return;
    final random = Random();
    _marketTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _symbols = _symbols.map((symbol) {
        final move = (random.nextDouble() - 0.5) * 0.01;
        final newPrice = symbol.price * (1 + move);
        final newChange = symbol.change + (move * 100);
        return symbol.copyWith(price: newPrice, change: newChange);
      }).toList();
      _symbolController.add(List<MarketSymbolModel>.from(_symbols));
    });
  }
}
