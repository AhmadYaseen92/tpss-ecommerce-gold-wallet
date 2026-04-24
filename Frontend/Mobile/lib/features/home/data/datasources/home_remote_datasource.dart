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
            final isHasOffer = _asBool(item['isHasOffer'] ?? item['IsHasOffer']);
            final offerPercent = (item['offerPercent'] as num?)?.toDouble() ?? 0;
            final offerType = (item['offerType'] ?? '').toString();
            final sellPrice = (item['sellPrice'] as num?)?.toDouble() ?? 0;
            final pricingMode = (item['pricingMode'] ?? '').toString().toLowerCase();
            final sourcePrice = _inactivePrice(
              sellPrice: sellPrice,
              baseMarketPrice: (item['baseMarketPrice'] as num?)?.toDouble() ?? 0,
              autoPrice: (item['autoPrice'] as num?)?.toDouble() ?? 0,
              fixedPrice: (item['fixedPrice'] as num?)?.toDouble() ?? 0,
              offerNewPrice: (item['offerNewPrice'] as num?)?.toDouble() ?? 0,
              offerPercent: offerPercent,
            );
            return HomeCarsouleItemModel(
              id: (item['id'] ?? '').toString(),
              imgUrl: (item['imageUrl'] ?? '').toString(),
              title: (item['name'] ?? 'Product').toString(),
              sellerName: (item['sellerName'] ?? 'Seller').toString(),
              materialType: _materialTypeLabel(item['materialType']),
              pricingModeLabel: pricingMode.contains('auto') ? 'Auto Price' : 'Manual Price',
              sourcePrice: sourcePrice,
              sellPrice: sellPrice,
              offerLabel: _offerLabel(
                isHasOffer: isHasOffer,
                offerPercent: offerPercent,
                offerType: offerType,
                sellPrice: sellPrice,
              ),
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


  bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }

    final normalized = (value ?? '').toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  String? _offerLabel({
    required bool isHasOffer,
    required double offerPercent,
    required String offerType,
    required double sellPrice,
  }) {
    if (!isHasOffer) {
      return null;
    }
    if (offerType.toLowerCase().contains('percent') && offerPercent > 0) {
      return '${offerPercent.toStringAsFixed(0)}% OFF';
    }
    if (offerType.toLowerCase() != 'none') {
      return 'Offer • Now ${sellPrice.toStringAsFixed(2)} JOD';
    }
    return null;
  }

  double _inactivePrice({
    required double sellPrice,
    required double baseMarketPrice,
    required double autoPrice,
    required double fixedPrice,
    required double offerNewPrice,
    required double offerPercent,
  }) {
    final candidates = <double>[baseMarketPrice, autoPrice, fixedPrice, offerNewPrice];
    final direct = candidates.firstWhere(
      (price) => price > 0 && price > sellPrice,
      orElse: () => 0,
    );
    if (direct > 0) return direct;

    if (offerPercent > 0 && offerPercent < 100 && sellPrice > 0) {
      final calculated = sellPrice / (1 - (offerPercent / 100));
      if (calculated > sellPrice) {
        return calculated;
      }
    }
    return sellPrice;
  }

  String _materialTypeLabel(dynamic rawMaterialType) {
    if (rawMaterialType is num) {
      return switch (rawMaterialType.toInt()) {
        1 => 'Gold',
        2 => 'Silver',
        3 => 'Diamond',
        _ => 'Gold',
      };
    }

    final normalized = (rawMaterialType ?? '').toString().trim();
    if (normalized.isEmpty) return 'Gold';

    final asInt = int.tryParse(normalized);
    if (asInt != null) {
      return _materialTypeLabel(asInt);
    }

    final lower = normalized.toLowerCase();
    if (lower == 'gold' || lower == 'silver' || lower == 'diamond') {
      return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }
    return normalized;
  }
}
