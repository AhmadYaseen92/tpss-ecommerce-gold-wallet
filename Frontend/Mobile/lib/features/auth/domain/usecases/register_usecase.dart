import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final IAuthRepository _repository;

  Future<String> call({
    required String firstName,
    required String middleName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    String? dateOfBirth,
    String? nationality,
    String? documentType,
    String? idNumber,
    String? profilePhotoUrl,
    String? preferredLanguage,
    String? preferredTheme,
    String marketType = 'UAE',
    int sellerId = 0,
  }) {
    return _repository.register(
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      dateOfBirth: dateOfBirth,
      nationality: nationality,
      documentType: documentType,
      idNumber: idNumber,
      profilePhotoUrl: profilePhotoUrl,
      preferredLanguage: preferredLanguage,
      preferredTheme: preferredTheme,
      marketType: marketType,
      sellerId: sellerId,
    );
  }
}
