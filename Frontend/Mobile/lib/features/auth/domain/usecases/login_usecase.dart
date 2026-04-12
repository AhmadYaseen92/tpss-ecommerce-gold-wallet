import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/entities/auth_session.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final IAuthRepository _repository;

  Future<AuthSession> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
