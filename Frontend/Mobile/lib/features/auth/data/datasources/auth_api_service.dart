import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/data/models/auth_models.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  @POST('/auth/login')
  Future<Map<String, dynamic>> login(@Body() LoginRequestModel request);

  @POST('/auth/register')
  Future<Map<String, dynamic>> register(@Body() RegisterRequestModel request);
}
