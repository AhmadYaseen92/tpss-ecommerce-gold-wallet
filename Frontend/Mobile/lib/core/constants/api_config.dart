class ApiConfig {
  const ApiConfig._();

  static const String serverIp = '192.168.1.2';
  static const String serverPort = '5095';
  static const String apiPrefix = '/api';

  static const String baseUrl =
      String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://$serverIp:$serverPort$apiPrefix',
      );
}
