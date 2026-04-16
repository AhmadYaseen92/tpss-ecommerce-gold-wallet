import 'dart:async';

import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';

class RealtimeRefreshService {
  RealtimeRefreshService({Duration fallbackInterval = const Duration(seconds: 2)})
    : _fallbackInterval = fallbackInterval;

  final Duration _fallbackInterval;
  final StreamController<String> _refreshController = StreamController<String>.broadcast();

  Timer? _fallbackTimer;

  Stream<String> get refreshes => _refreshController.stream;

  Future<void> ensureStarted() async {
    final token = AuthSessionStore.accessToken;
    if (token == null || token.isEmpty) {
      await stop();
      return;
    }

    _startFallbackTimer();
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
  }

  Future<void> dispose() async {
    await stop();
    await _refreshController.close();
  }
}
