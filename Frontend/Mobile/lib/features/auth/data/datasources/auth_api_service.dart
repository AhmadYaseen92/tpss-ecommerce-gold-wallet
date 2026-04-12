import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/data/models/auth_models.dart';

class AuthApiService {
  AuthApiService(this._dio, {String? baseUrl}) : _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  Future<Map<String, dynamic>> login(LoginRequestModel request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
      options: Options(baseUrl: _resolveBaseUrl()),
    );

    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> register(RegisterRequestModel request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: request.toJson(),
      options: Options(baseUrl: _resolveBaseUrl()),
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
