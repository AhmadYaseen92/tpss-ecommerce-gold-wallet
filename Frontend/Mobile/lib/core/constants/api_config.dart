class ApiConfig {
  ApiConfig._();

  static const String serverIp = '192.168.68.108';
  static const String serverPort = '5095';
  static const String apiPrefix = '/api';

  static String baseUrl = _normalize(
    const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://$serverIp:$serverPort$apiPrefix',
    ),
  );

  static int timeoutSeconds = int.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: 20,
  );

  static void updateBaseUrl(String value) {
    final normalized = _normalize(value);
    if (normalized.isNotEmpty) {
      baseUrl = normalized;
    }
  }

  static void updateTimeout(int seconds) {
    if (seconds > 0) {
      timeoutSeconds = seconds;
    }
  }

  static String _normalize(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
