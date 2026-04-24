import 'package:tpss_ecommerce_gold_wallet/core/constants/api_config.dart';

String resolveServerUrl(String? rawUrl) {
  final trimmed = (rawUrl ?? '').trim();
  if (trimmed.isEmpty) return '';

  final parsed = Uri.tryParse(trimmed);
  if (parsed != null && parsed.hasScheme && (parsed.scheme == 'http' || parsed.scheme == 'https')) {
    return parsed.toString();
  }

  final apiBase = Uri.tryParse(ApiConfig.baseUrl);
  if (apiBase == null) return trimmed;

  final normalizedPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '${apiBase.scheme}://${apiBase.host}${apiBase.hasPort ? ':${apiBase.port}' : ''}$normalizedPath';
}
