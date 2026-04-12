// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_service.dart';

class _AuthApiService implements AuthApiService {
  _AuthApiService(this._dio, {this.baseUrl});

  final Dio _dio;

  String? baseUrl;

  @override
  Future<Map<String, dynamic>> login(LoginRequestModel request) async {
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());

    final _result = await _dio.fetch<Map<String, dynamic>>(
      Options(
        method: 'POST',
      ).compose(
        _dio.options,
        '/auth/login',
        data: _data,
      ).copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );

    return _result.data ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> register(RegisterRequestModel request) async {
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());

    final _result = await _dio.fetch<Map<String, dynamic>>(
      Options(
        method: 'POST',
      ).compose(
        _dio.options,
        '/auth/register',
        data: _data,
      ).copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );

    return _result.data ?? <String, dynamic>{};
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final uri = Uri.parse(baseUrl);

    if (uri.isAbsolute) {
      return uri.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(uri).toString();
  }
}
