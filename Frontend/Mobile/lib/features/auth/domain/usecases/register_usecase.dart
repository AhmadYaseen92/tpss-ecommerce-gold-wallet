import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final IAuthRepository _repository;

  Future<String> call({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    String? dateOfBirth,
    String? nationality,
    String? preferredLanguage,
    String? preferredTheme,
  }) {
    return _repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      dateOfBirth: dateOfBirth,
      nationality: nationality,
      preferredLanguage: preferredLanguage,
      preferredTheme: preferredTheme,
    );
  }
}
