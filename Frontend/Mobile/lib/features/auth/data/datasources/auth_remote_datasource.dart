import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/data/datasources/auth_api_service.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/data/models/auth_models.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiService);

  final AuthApiService _apiService;

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.login(
      LoginRequestModel(email: email, password: password),
    );

    final envelope = ApiEnvelope<LoginResponseModel>.fromJson(
      response,
      (json) => LoginResponseModel.fromJson(json! as Map<String, dynamic>),
    );

    if (!envelope.success || envelope.data == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        error: envelope.errors.isNotEmpty
            ? envelope.errors.join(', ')
            : envelope.message,
      );
    }

    return envelope.data!;
  }

  Future<void> register({
    required RegisterRequestModel request,
  }) async {
    final response = await _apiService.register(request);
    final envelope = ApiEnvelope<Map<String, dynamic>?>.fromJson(
      response,
      (json) => json as Map<String, dynamic>?,
    );

    if (!envelope.success) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/register'),
        error: envelope.errors.isNotEmpty
            ? envelope.errors.join(', ')
            : envelope.message,
      );
    }
  }
}
