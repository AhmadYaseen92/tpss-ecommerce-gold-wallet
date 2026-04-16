import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/api_config.dart';

class RealtimeRefreshService {
  RealtimeRefreshService({Duration fallbackInterval = const Duration(seconds: 2)})
    : _fallbackInterval = fallbackInterval;

  final Duration _fallbackInterval;
  final StreamController<String> _refreshController = StreamController<String>.broadcast();

  HubConnection? _connection;
  bool _isStarting = false;
  Timer? _fallbackTimer;

  Stream<String> get refreshes => _refreshController.stream;

  Future<void> ensureStarted() async {
    final token = AuthSessionStore.accessToken;
    if (token == null || token.isEmpty) {
      await stop();
      return;
    }

    if (_connection?.state == HubConnectionState.Connected || _isStarting) {
      return;
    }

    _isStarting = true;
    try {
      final baseUrl = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
      final connection = HubConnectionBuilder()
          .withUrl(
            '$baseUrl/hubs/marketplace',
            options: HttpConnectionOptions(
              accessTokenFactory: () async => AuthSessionStore.accessToken ?? '',
            ),
          )
          .withAutomaticReconnect()
          .build();

      connection.onclose((_) => _startFallbackTimer());
      connection.on('MarketplaceRefreshRequested', (arguments) {
        final reason = arguments?.isNotEmpty == true
            ? arguments?.first?.toString() ?? 'signalr'
            : 'signalr';
        _refreshController.add(reason);
      });

      await connection.start();
      _connection = connection;
      _stopFallbackTimer();
    } catch (_) {
      _startFallbackTimer();
    } finally {
      _isStarting = false;
    }
  }

  void _startFallbackTimer() {
    if (_fallbackTimer != null) return;
    _fallbackTimer = Timer.periodic(_fallbackInterval, (_) {
      _refreshController.add('fallback-polling');
    });
  }

  void _stopFallbackTimer() {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
  }

  Future<void> stop() async {
    _stopFallbackTimer();
    final connection = _connection;
    _connection = null;
    if (connection != null) {
      await connection.stop();
    }
  }

  Future<void> dispose() async {
    await stop();
    await _refreshController.close();
  }
}
