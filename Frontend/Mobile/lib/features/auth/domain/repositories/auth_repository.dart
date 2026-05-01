import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/entities/auth_session.dart';

abstract class IAuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<String> register({
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
  });
}
