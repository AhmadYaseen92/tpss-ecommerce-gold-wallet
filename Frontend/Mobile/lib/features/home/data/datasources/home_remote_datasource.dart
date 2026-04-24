import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/data/models/home_carousel_Item_model.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<HomeCarsouleItemModel>> getCarouselProductsWithOffers({
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.post(
        '/products/search',
        data: {
          'pageNumber': 1,
          'pageSize': pageSize,
        },
      );
      final payload = response.data as Map<String, dynamic>?;
      final data = payload?['data'] as Map<String, dynamic>?;
      final items = data?['items'] as List<dynamic>? ?? const [];
      final mapped = items
          .whereType<Map<String, dynamic>>()
          .map((item) {
            final offerPercent = (item['offerPercent'] as num?)?.toDouble() ?? 0;
            final offerType = (item['offerType'] ?? '').toString();
            final sellPrice = (item['sellPrice'] as num?)?.toDouble() ?? 0;
            final pricingMode = (item['pricingMode'] ?? '').toString().toLowerCase();
            final sourcePrice = pricingMode.contains('auto')
                ? ((item['autoPrice'] as num?)?.toDouble() ?? sellPrice)
                : ((item['fixedPrice'] as num?)?.toDouble() ?? sellPrice);
            return HomeCarsouleItemModel(
              id: (item['id'] ?? '').toString(),
              imgUrl: (item['imageUrl'] ?? '').toString(),
              title: (item['name'] ?? 'Product').toString(),
              sellerName: (item['sellerName'] ?? 'Seller').toString(),
              materialType: (item['materialType'] ?? 'Gold').toString(),
              pricingModeLabel: pricingMode.contains('auto') ? 'Auto Price' : 'Manual Price',
              sourcePrice: sourcePrice,
              sellPrice: sellPrice,
              offerLabel: _offerLabel(offerPercent: offerPercent, offerType: offerType, sellPrice: sellPrice),
            );
          })
          .where((item) => item.imgUrl.trim().isNotEmpty)
          .where((item) => (item.offerLabel ?? '').trim().isNotEmpty)
          .toList();

      return mapped;
    } catch (_) {
      return const [];
    }
  }

  String? _offerLabel({
    required double offerPercent,
    required String offerType,
    required double sellPrice,
  }) {
    if (offerType.toLowerCase().contains('percent') && offerPercent > 0) {
      return '${offerPercent.toStringAsFixed(0)}% OFF';
    }
    if (offerType.toLowerCase() != 'none') {
      return 'Offer • Now ${sellPrice.toStringAsFixed(2)} JOD';
    }
    return null;
  }
}
