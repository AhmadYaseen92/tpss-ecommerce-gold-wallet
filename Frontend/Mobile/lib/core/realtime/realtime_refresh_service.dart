import 'dart:async';

import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/api_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/services/signalr_service.dart';

class RealtimeRefreshService {
  RealtimeRefreshService({Duration fallbackInterval = const Duration(seconds: 5)})
    : _fallbackInterval = fallbackInterval;

  final Duration _fallbackInterval;
  final StreamController<String> _refreshController = StreamController<String>.broadcast();

  Timer? _fallbackTimer;
  SignalRService? _signalRService;
  String? _activeToken;
  bool _isStarting = false;

  Stream<String> get refreshes => _refreshController.stream;

  Future<void> ensureStarted() async {
    final token = AuthSessionStore.accessToken;
    if (token == null || token.isEmpty) {
      await stop();
      return;
    }

    if (_activeToken == token && _signalRService != null) {
      return;
    }

    if (_isStarting) return;
    _isStarting = true;
    try {
      await _signalRService?.disconnect();
      _signalRService = SignalRService(
        baseUrl: ApiConfig.baseUrl,
        accessToken: token,
        onEvent: (event, _) {
          _refreshController.add('signalr:$event');
        },
        onConnectionStateChanged: (isConnected) {
          if (isConnected) {
            _stopFallbackTimer();
            return;
          }
          _startFallbackTimer();
        },
      );

      try {
        await _signalRService!.connect();
        _activeToken = token;
        _stopFallbackTimer();
      } catch (_) {
        _startFallbackTimer();
      }
    } finally {
      _isStarting = false;
    }
  }

  void _startFallbackTimer() {
    if (_fallbackTimer != null) return;
    _fallbackTimer = Timer.periodic(_fallbackInterval, (_) {
      _refreshController.add('fallback-polling');
      if (_signalRService == null && !_isStarting) {
        unawaited(ensureStarted());
      }
    });
  }

  void _stopFallbackTimer() {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
  }

  Future<void> stop() async {
    _stopFallbackTimer();
    await _signalRService?.disconnect();
    _signalRService = null;
    _activeToken = null;
  }

  Future<void> dispose() async {
    await stop();
    await _refreshController.close();
  }
}
