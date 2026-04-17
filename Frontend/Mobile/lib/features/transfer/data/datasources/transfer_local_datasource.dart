import 'package:dio/dio.dart';

class TransferLocalDataSource {
  TransferLocalDataSource(this._dio);

  final Dio _dio;

  Future<bool> isRegisteredAccount(String accountNumber) async {
    if (accountNumber.trim().isEmpty) return false;
    final response = await _dio.get(
      '/wallet/investors/lookup',
      queryParameters: {'accountNumber': accountNumber.trim()},
    );
    final payload = (response.data as Map<String, dynamic>)['data'];
    return payload is Map<String, dynamic>;
  }
}
