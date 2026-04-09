import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/entities/auth_session.dart';

abstract class IAuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  });
}
