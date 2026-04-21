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
          .where((item) => (item['isHasOffer'] as bool?) ?? false)
          .map((item) {
            final offerPercent = (item['offerPercent'] as num?)?.toDouble() ?? 0;
            final offerNewPrice = (item['offerNewPrice'] as num?)?.toDouble() ?? 0;
            return HomeCarsouleItemModel(
              id: (item['id'] ?? '').toString(),
              imgUrl: (item['imageUrl'] ?? '').toString(),
              title: (item['name'] ?? 'Product').toString(),
              sellerName: (item['sellerName'] ?? 'Seller').toString(),
              offerLabel: _offerLabel(offerPercent: offerPercent, offerNewPrice: offerNewPrice),
            );
          })
          .where((item) => item.imgUrl.trim().isNotEmpty)
          .toList();

      return mapped;
    } catch (_) {
      return const [];
    }
  }

  String? _offerLabel({
    required double offerPercent,
    required double offerNewPrice,
  }) {
    if (offerPercent > 0) {
      return '${offerPercent.toStringAsFixed(0)}% OFF';
    }
    if (offerNewPrice > 0) {
      return 'Offer \$${offerNewPrice.toStringAsFixed(2)}';
    }
    return 'Special Offer';
  }
}
