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
                                          if (AppReleaseConfig
                                              .showSellerUi) ...[
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
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Last: 1m',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.grey,
                                              fontWeight: FontWeight.w600,
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
                                            value: _ask(
                                              item,
                                            ).toStringAsFixed(2),
                                          ),
                                          _marketValueLine(
                                            context,
                                            label: 'Bid',
                                            value: _bid(
                                              item,
                                            ).toStringAsFixed(2),
                                          ),
                                          _marketValueLine(
                                            context,
                                            label: 'High',
                                            value: _high(
                                              item,
                                            ).toStringAsFixed(2),
                                          ),
                                          _marketValueLine(
                                            context,
                                            label: 'Low',
                                            value: _low(
                                              item,
                                            ).toStringAsFixed(2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _SymbolMiniChart(
                                  points: _chartPoints(item, length: 22),
                                  isPositive: item.change >= 0,
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
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed(AppRoutes.marketOrderCheckoutRoute);
                },
                icon: const Icon(Icons.add_card),
                label: const Text('Place Order'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openMarketDetail(BuildContext context, MarketSymbolModel item) {
    String interval = '1 Minute';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.symbol,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: interval,
                        items: const [
                          DropdownMenuItem(
                            value: '1 Minute',
                            child: Text('1 Minute'),
                          ),
                          DropdownMenuItem(
                            value: '30 Min',
                            child: Text('30 Min'),
                          ),
                          DropdownMenuItem(
                            value: '1 Hour',
                            child: Text('1 Hour'),
                          ),
                          DropdownMenuItem(value: 'Day', child: Text('Day')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => interval = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppReleaseConfig.showSellerUi
                        ? '${item.name} • Seller: ${item.sellerName}'
                        : item.name,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'X: Pricing   |   Y: Time',
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 230,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: _SymbolMiniChart(
                                  points: _chartPoints(
                                    item,
                                    length: _lengthForInterval(interval),
                                  ),
                                  isPositive: item.change >= 0,
                                  showGrid: true,
                                  strokeWidth: 2.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Text(
                                    'Last 1m',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    interval,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 54,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _high(item).toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.grey,
                                ),
                              ),
                              Text(
                                item.price.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.grey,
                                ),
                              ),
                              Text(
                                _low(item).toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 4),
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
      },
    );
  }

  int _lengthForInterval(String interval) {
    switch (interval) {
      case '30 Min':
        return 35;
      case '1 Hour':
        return 42;
      case 'Day':
        return 50;
      case '1 Minute':
      default:
        return 22;
    }
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

  List<double> _chartPoints(MarketSymbolModel item, {required int length}) {
    return List<double>.generate(length, (index) {
      final seed = (item.symbol.hashCode % 100) / 1000;
      final wave = math.sin((index / (length - 1)) * math.pi * 1.6);
      final drift = (item.change / 100) * (index / (length - 1));
      return item.price * (1 + seed + (wave * 0.004) + drift);
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

class _SymbolMiniChart extends StatelessWidget {
  final List<double> points;
  final bool isPositive;
  final bool showGrid;
  final double strokeWidth;

  const _SymbolMiniChart({
    required this.points,
    required this.isPositive,
    this.showGrid = false,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.green : AppColors.red;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withAlpha(20),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 70),
        painter: _SparklinePainter(
          points: points,
          color: color,
          showGrid: showGrid,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;
  final bool showGrid;
  final double strokeWidth;

  _SparklinePainter({
    required this.points,
    required this.color,
    required this.showGrid,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final minY = points.reduce(math.min);
    final maxY = points.reduce(math.max);
    final range = (maxY - minY).abs() < 0.0001 ? 1.0 : (maxY - minY);

    if (showGrid) {
      final gridPaint = Paint()
        ..color = AppColors.grey.withAlpha(45)
        ..strokeWidth = 1;
      for (var i = 1; i <= 3; i++) {
        final y = (size.height / 4) * i;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
      for (var i = 1; i <= 5; i++) {
        final x = (size.width / 6) * i;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
    }

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - ((points[i] - minY) / range * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
