import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_server_image.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/data/datasources/home_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/data/models/home_carousel_Item_model.dart';

class HomeCarouselWidget extends StatefulWidget {
  const HomeCarouselWidget({super.key});

  @override
  State<HomeCarouselWidget> createState() => _HomeCarouselWidgetState();
}

class _HomeCarouselWidgetState extends State<HomeCarouselWidget> {
  final HomeRemoteDataSource _remoteDataSource = HomeRemoteDataSource(InjectionContainer.dio());
  StreamSubscription<String>? _realtimeSubscription;
  List<HomeCarsouleItemModel> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    unawaited(_bindRealtime());
  }

  Future<void> _bindRealtime() async {
    await InjectionContainer.realtimeRefreshService().ensureStarted();
    _realtimeSubscription = InjectionContainer.realtimeRefreshService().refreshes.listen((_) {
      unawaited(_load(silent: true));
    });
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() => _loading = true);
    }
    final data = await _remoteDataSource.getCarouselProductsWithOffers();
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (_items.isEmpty) {
      return Container(
        height: 140,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withAlpha(10),
        ),
        child: const Text('No offer products available right now.'),
      );
    }

    return FlutterCarousel.builder(
      itemCount: _items.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
        final item = _items[itemIndex];
        final hasOffer = (item.offerLabel ?? '').isNotEmpty;
        final hasInactivePrice = item.sourcePrice > item.sellPrice;
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Color(0x11000000)),
                AppServerImage(
                  imageUrl: item.imgUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholderIconSize: 28,
                  backgroundColor: const Color(0x1A000000),
                  iconColor: Colors.white70,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(30),
                        Colors.black.withAlpha(140),
                      ],
                    ),
                  ),
                ),
                if (hasOffer)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        item.offerLabel!,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(item.materialType, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(item.sellerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                      if (hasOffer && hasInactivePrice)
                        Text('\$${item.sourcePrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 11, decoration: TextDecoration.lineThrough)),
                      Text('\$${item.sellPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      options: FlutterCarouselOptions(
        height: 220.0,
        autoPlay: true,
        showIndicator: false,
        enlargeCenterPage: true,
        slideIndicator: CircularSlideIndicator(),
      ),
    );
  }
}
