import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/models/market_symbol_model.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/product_cubit/product_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/product/widgets/seller_filter_bar_widget.dart';

class MarketWatchTabWidget extends StatelessWidget {
  const MarketWatchTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      buildWhen: (_, current) =>
          current is ProductMarketWatchLoaded || current is ProductLoaded,
      builder: (context, state) {
        final cubit = context.read<ProductCubit>();
        final symbols = state is ProductMarketWatchLoaded
            ? state.symbols
            : cubit.visibleMarketSymbols;

        return Stack(
          children: [
            Column(
              children: [
                const SellerFilterBarWidget(),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 84),
                    itemCount: symbols.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = symbols[index];
                      return Card(
                        color: AppColors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _openMarketDetail(context, item),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.symbol,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(item.name),
                                          if (AppReleaseConfig.showSellerUi) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Seller: ${item.sellerName}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.darkGold,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 4),
                                          Text(
                                            'Updated: ${_formatUpdatedTime(DateTime.now())}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          _marketValueLine(
                                            context,
                                            label: 'Ask',
                                            value: _ask(item).toStringAsFixed(2),
                                          ),
                                          _marketValueLine(
                                            context,
                                            label: 'Bid',
                                            value: _bid(item).toStringAsFixed(2),
                                          ),
                                          _marketValueLine(
                                            context,
                                            label: 'High',
                                            value: _high(item).toStringAsFixed(2),
                                          ),
                                          _marketValueLine(
                                            context,
                                            label: 'Low',
                                            value: _low(item).toStringAsFixed(2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _MiniCandleChart(
                                  candles: _buildCandles(item, 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pushNamed(
                    AppRoutes.marketOrderCheckoutRoute,
                  );
                },
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Place Order'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openMarketDetail(BuildContext context, MarketSymbolModel item) {
    final candles = _buildCandles(item, 60);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.menu, size: 20),
                  SizedBox(width: 10),
                  Icon(Icons.show_chart, size: 20),
                  SizedBox(width: 10),
                  Icon(Icons.gps_fixed, size: 20),
                  SizedBox(width: 10),
                  Icon(Icons.remove, size: 20),
                  SizedBox(width: 10),
                  Icon(Icons.add, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    item.symbol,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 10),
                  const Text('M1', style: TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 320,
                child: _DetailedCandleChart(
                  candles: candles,
                  bidLine: _bid(item),
                  askLine: _ask(item),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppReleaseConfig.showSellerUi
                    ? '${item.name} • Seller: ${item.sellerName}'
                    : item.name,
              ),
              const SizedBox(height: 8),
              Text(
                'Live Price: \$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'Ask ${_ask(item).toStringAsFixed(2)} • Bid ${_bid(item).toStringAsFixed(2)}',
              ),
              Text(
                'High ${_high(item).toStringAsFixed(2)} • Low ${_low(item).toStringAsFixed(2)}',
              ),
              Text(
                'Updated: ${_formatUpdatedTime(DateTime.now())}',
                style: const TextStyle(color: AppColors.grey),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context, rootNavigator: true).pushNamed(
                      AppRoutes.marketOrderCheckoutRoute,
                      arguments: {
                        'title': item.symbol,
                        'seller': item.sellerName,
                        'amount': item.price,
                      },
                    );
                  },
                  child: const Text('Place Order'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _marketValueLine(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(color: AppColors.grey),
            ),
            TextSpan(
              text: '\$$value',
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_CandleData> _buildCandles(MarketSymbolModel item, int count) {
    final seed = item.symbol.hashCode.abs() % 997;
    final rng = math.Random(seed);
    var prevClose = item.price * (0.992 + rng.nextDouble() * 0.01);

    return List<_CandleData>.generate(count, (i) {
      final drift = item.change / 1000;
      final open = prevClose;
      final change = ((rng.nextDouble() - 0.5) * 0.009) + drift;
      final close = open * (1 + change);
      final wickRange = open * (0.0012 + rng.nextDouble() * 0.0018);
      final high = math.max(open, close) + wickRange;
      final low = math.min(open, close) - wickRange;
      prevClose = close;
      return _CandleData(open: open, high: high, low: low, close: close, index: i);
    });
  }

  String _formatUpdatedTime(DateTime time) {
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final year = time.year.toString();
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    final millisecond = time.millisecond.toString().padLeft(3, '0');
    return '$year-$month-$day $hour:$minute:$second.$millisecond';
  }

  double _ask(MarketSymbolModel item) => item.price * 1.0015;
  double _bid(MarketSymbolModel item) => item.price * 0.9985;
  double _high(MarketSymbolModel item) => item.price * 1.01;
  double _low(MarketSymbolModel item) => item.price * 0.99;
}

class _MiniCandleChart extends StatelessWidget {
  final List<_CandleData> candles;

  const _MiniCandleChart({required this.candles});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.grey.withAlpha(20),
      ),
      child: CustomPaint(
        painter: _CandlePainter(candles: candles, showGrid: false, showPrices: false),
      ),
    );
  }
}

class _DetailedCandleChart extends StatelessWidget {
  final List<_CandleData> candles;
  final double bidLine;
  final double askLine;

  const _DetailedCandleChart({
    required this.candles,
    required this.bidLine,
    required this.askLine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey.withAlpha(60)),
      ),
      child: CustomPaint(
        painter: _CandlePainter(
          candles: candles,
          showGrid: true,
          showPrices: true,
          askLine: askLine,
          bidLine: bidLine,
        ),
      ),
    );
  }
}

class _CandleData {
  final double open;
  final double high;
  final double low;
  final double close;
  final int index;

  const _CandleData({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.index,
  });
}

class _CandlePainter extends CustomPainter {
  final List<_CandleData> candles;
  final bool showGrid;
  final bool showPrices;
  final double? askLine;
  final double? bidLine;

  _CandlePainter({
    required this.candles,
    required this.showGrid,
    required this.showPrices,
    this.askLine,
    this.bidLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final allHighs = candles.map((e) => e.high).toList();
    final allLows = candles.map((e) => e.low).toList();
    final maxY = allHighs.reduce(math.max);
    final minY = allLows.reduce(math.min);
    final range = (maxY - minY).abs() < 0.000001 ? 1.0 : (maxY - minY);
    const rightGutter = 58.0;
    final chartWidth = size.width - rightGutter;

    double toY(double v) => size.height - ((v - minY) / range) * size.height;

    if (showGrid) {
      final gridPaint = Paint()
        ..color = AppColors.grey.withAlpha(70)
        ..strokeWidth = 0.7;

      for (var i = 0; i <= 8; i++) {
        final y = (size.height / 8) * i;
        canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
      }
      for (var i = 0; i <= 8; i++) {
        final x = (chartWidth / 8) * i;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
    }

    final candleSpace = chartWidth / candles.length;
    final bodyWidth = (candleSpace * 0.58).clamp(2.2, 8.0).toDouble();

    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      final x = (i * candleSpace) + (candleSpace / 2);
      final openY = toY(c.open);
      final closeY = toY(c.close);
      final highY = toY(c.high);
      final lowY = toY(c.low);
      final bullish = c.close >= c.open;
      final color = bullish ? const Color(0xFF59BC6E) : const Color(0xFFF35B52);

      final wickPaint = Paint()
        ..color = color
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

      final top = math.min(openY, closeY);
      final bottom = math.max(openY, closeY);
      final rect = Rect.fromLTRB(x - bodyWidth / 2, top, x + bodyWidth / 2, bottom + 0.8);
      canvas.drawRect(rect, Paint()..color = color);
    }

    if (askLine != null) {
      final y = toY(askLine!);
      final p = Paint()
        ..color = const Color(0xFFF35B52)
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), p);
      _drawPriceTag(canvas, Offset(chartWidth + 2, y), askLine!, const Color(0xFFF35B52));
    }

    if (bidLine != null) {
      final y = toY(bidLine!);
      final p = Paint()
        ..color = const Color(0xFF59BC6E)
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), p);
      _drawPriceTag(canvas, Offset(chartWidth + 2, y), bidLine!, const Color(0xFF59BC6E));
    }

    if (showPrices) {
      final tp = TextPainter(textDirection: TextDirection.ltr);
      for (var i = 0; i <= 8; i++) {
        final value = maxY - ((range / 8) * i);
        final y = (size.height / 8) * i;
        tp.text = TextSpan(
          text: value.toStringAsFixed(2),
          style: const TextStyle(fontSize: 11, color: AppColors.grey),
        );
        tp.layout();
        tp.paint(canvas, Offset(chartWidth + 4, y - (tp.height / 2)));
      }
    }
  }

  void _drawPriceTag(Canvas canvas, Offset anchor, double value, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: value.toStringAsFixed(2),
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final tagRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(anchor.dx, anchor.dy - 10, textPainter.width + 10, 20),
      const Radius.circular(3),
    );
    canvas.drawRRect(tagRect, Paint()..color = color);
    textPainter.paint(canvas, Offset(anchor.dx + 5, anchor.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CandlePainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.askLine != askLine ||
        oldDelegate.bidLine != bidLine;
  }
}
