import 'package:signalr_core/signalr_core.dart';

typedef SignalREventHandler = void Function(String event, dynamic payload);

class SignalRService {
  final String baseUrl;
  final String accessToken;
  final SignalREventHandler onEvent;
  HubConnection? _connection;

  SignalRService({
    required this.baseUrl,
    required this.accessToken,
    required this.onEvent,
  });

  Future<void> connect() async {
    _connection = HubConnectionBuilder()
        .withUrl('$baseUrl/hubs/updates',
            HttpConnectionOptions(
              accessTokenFactory: () async => accessToken,
            ))
        .withAutomaticReconnect()
        .build();

    _connection?.on('ProductUpdated', (args) => onEvent('product', args));
    _connection?.on('DashboardUpdated', (args) => onEvent('dashboard', args));
    _connection?.on('TransactionUpdated', (args) => onEvent('transaction', args));
    _connection?.on('WalletUpdated', (args) => onEvent('wallet', args));

    await _connection?.start();
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
  }
}
