import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/data/models/auth_models.dart';

class AuthApiService {
  AuthApiService(this._dio, {String? baseUrl}) : _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  Future<Map<String, dynamic>> login(LoginRequestModel request) async {
    final data = request.toJson();

    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST')
          .compose(_dio.options, '/auth/login', data: data)
          .copyWith(baseUrl: _resolveBaseUrl()),
    );

    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> register(RegisterRequestModel request) async {
    final data = request.toJson();

    final response = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'POST')
          .compose(_dio.options, '/auth/register', data: data)
          .copyWith(baseUrl: _resolveBaseUrl()),
    );

    return response.data ?? <String, dynamic>{};
  }

  String _resolveBaseUrl() {
    final configuredBaseUrl = (_baseUrl ?? '').trim();
    if (configuredBaseUrl.isEmpty) {
      return _dio.options.baseUrl;
    }

    final uri = Uri.parse(configuredBaseUrl);
    if (uri.isAbsolute) {
      return uri.toString();
    }

    return Uri.parse(_dio.options.baseUrl).resolveUri(uri).toString();
  }
}
