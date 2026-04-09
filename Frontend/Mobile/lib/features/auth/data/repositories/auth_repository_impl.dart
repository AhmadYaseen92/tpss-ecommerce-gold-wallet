import 'package:tpss_ecommerce_gold_wallet/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/data/models/auth_models.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/entities/auth_session.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(email: email, password: password);
    return AuthSession(
      accessToken: result.accessToken,
      expiresAtUtc: result.expiresAtUtc,
      role: result.role,
      userId: result.userId,
    );
  }

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) {
    return _remoteDataSource.register(
      request: RegisterRequestModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      ),
    );
  }
}
