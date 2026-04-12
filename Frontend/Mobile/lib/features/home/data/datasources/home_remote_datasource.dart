import 'package:dio/dio.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<String>> getCarouselImageUrls() async {
    try {
      final response = await _dio.get('/mobile-app-configurations/home-carousel-images');
      final payload = response.data as Map<String, dynamic>?;
      final data = payload?['data'];

      if (data is List) {
        return data.map((item) => item.toString()).where((url) => url.isNotEmpty).toList();
      }

      if (data is Map<String, dynamic>) {
        final images = data['images'];
        if (images is List) {
          return images.map((item) => item.toString()).where((url) => url.isNotEmpty).toList();
        }
      }

      return const [];
    } catch (_) {
      return const [];
    }
  }
}
