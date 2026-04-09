import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/api_config.dart';

class DioFactory {
  const DioFactory._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(seconds: ApiConfig.timeoutSeconds),
        receiveTimeout: Duration(seconds: ApiConfig.timeoutSeconds),
        sendTimeout: Duration(seconds: ApiConfig.timeoutSeconds),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );

    return dio;
  }
}
