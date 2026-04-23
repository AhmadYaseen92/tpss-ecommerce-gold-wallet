import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/session_manager.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/api_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/network/api_error_parser.dart';

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
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.path.contains('/auth/login') && !options.path.contains('/auth/refresh-token')) {
            if (SessionManager.shouldRefreshAccessTokenProactively) {
              try {
                await SessionManager.refreshTokenIfNeeded();
              } catch (_) {}
            }
          }

          final token = AuthSessionStore.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode ?? 0;
          final request = error.requestOptions;
          final isRefreshPath = request.path.contains('/auth/refresh-token');
          final alreadyRetried = request.extra['retried'] == true;

          if (status == 401 && !isRefreshPath && !alreadyRetried && SessionManager.hasValidRefreshToken) {
            try {
              await SessionManager.refreshTokenIfNeeded();
              final retryOptions = Options(
                method: request.method,
                headers: {
                  ...request.headers,
                  'Authorization': 'Bearer ${AuthSessionStore.accessToken ?? ''}',
                },
              );
              request.extra['retried'] = true;
              final response = await dio.request<dynamic>(
                request.path,
                data: request.data,
                queryParameters: request.queryParameters,
                options: retryOptions,
              );
              return handler.resolve(response);
            } catch (_) {
              await SessionManager.forceLogout(localOnly: true);
            }
          }

          final friendly = ApiErrorParser.friendlyMessage(error);
          error.requestOptions.extra['friendlyMessage'] = friendly;
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
