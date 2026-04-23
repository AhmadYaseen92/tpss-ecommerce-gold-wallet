import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/api_config.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/data/models/auth_models.dart';

class SessionManager {
  SessionManager._();

  static Future<void>? _refreshFuture;

  static bool get hasValidRefreshToken {
    final token = AuthSessionStore.refreshToken;
    final expiry = AuthSessionStore.refreshTokenExpiresAtUtc;
    return token != null && token.isNotEmpty && expiry != null && expiry.isAfter(DateTime.now().toUtc());
  }

  static bool get shouldRefreshAccessTokenProactively {
    final expiry = AuthSessionStore.accessTokenExpiresAtUtc;
    if (expiry == null) return false;
    return expiry.difference(DateTime.now().toUtc()) <= const Duration(minutes: 1);
  }

  static Future<void> refreshTokenIfNeeded() async {
    if (_refreshFuture != null) return _refreshFuture!;

    _refreshFuture = () async {
      if (!hasValidRefreshToken) {
        await forceLogout(localOnly: true);
        throw Exception('Session expired.');
      }

      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(seconds: ApiConfig.timeoutSeconds),
        receiveTimeout: Duration(seconds: ApiConfig.timeoutSeconds),
      ));

      final response = await dio.post<Map<String, dynamic>>('/auth/refresh-token', data: {
        'refreshToken': AuthSessionStore.refreshToken,
      });

      final envelope = ApiEnvelope<LoginResponseModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (json) => LoginResponseModel.fromJson(json! as Map<String, dynamic>),
      );

      if (!envelope.success || envelope.data == null) {
        await forceLogout(localOnly: true);
        throw Exception('Unable to refresh session.');
      }

      final data = envelope.data!;
      await AuthSessionStore.setSession(
        token: data.accessToken,
        tokenExpiresAtUtc: data.expiresAtUtc,
        newRefreshToken: data.refreshToken,
        newRefreshTokenExpiresAtUtc: data.refreshTokenExpiresAtUtc,
        uid: data.userId,
        sid: data.sellerId,
      );
    }();

    try {
      await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }

  static Future<void> forceLogout({bool localOnly = false}) async {
    if (!localOnly && AuthSessionStore.accessToken != null) {
      try {
        final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
        await dio.post('/auth/logout',
            data: {'refreshToken': AuthSessionStore.refreshToken},
            options: Options(headers: {'Authorization': 'Bearer ${AuthSessionStore.accessToken}'}));
      } catch (_) {}
    }

    await AuthSessionStore.clearAll();
  }
}
