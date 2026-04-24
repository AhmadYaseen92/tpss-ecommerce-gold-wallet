import 'package:signalr_core/signalr_core.dart';

typedef SignalREventHandler = void Function(String event, dynamic payload);
typedef SignalRConnectionStateHandler = void Function(bool isConnected);

class SignalRService {
  final String baseUrl;
  final String accessToken;
  final SignalREventHandler onEvent;
  final SignalRConnectionStateHandler? onConnectionStateChanged;
  HubConnection? _connection;

  SignalRService({
    required this.baseUrl,
    required this.accessToken,
    required this.onEvent,
    this.onConnectionStateChanged,
  });

  Future<void> connect() async {
    _connection = HubConnectionBuilder()
        .withUrl('$baseUrl/hubs/marketplace',
            HttpConnectionOptions(
              accessTokenFactory: () async => accessToken,
            ))
        .withAutomaticReconnect()
        .build();

    _connection?.on('MarketplaceRefreshRequested', (args) => onEvent('marketplace-refresh', args));
    _connection?.on('WalletRefreshSignal', (args) => onEvent('wallet-refresh', args));

    _connection?.onreconnected((_) => onConnectionStateChanged?.call(true));
    _connection?.onreconnecting((_) => onConnectionStateChanged?.call(false));
    _connection?.onclose((_) => onConnectionStateChanged?.call(false));

    await _connection?.start();
    onConnectionStateChanged?.call(true);
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
  }
}
