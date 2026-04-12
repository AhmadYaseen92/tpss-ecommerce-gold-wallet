import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ProfileRemoteModel> getProfile() async {
    final userId = _requireUserId();
    final response = await _dio.post('/profile/by-user', data: {'userId': userId});
    final payload = response.data as Map<String, dynamic>;
    final data = payload['data'] as Map<String, dynamic>;
    return ProfileRemoteModel.fromJson(data);
  }

  Future<void> updatePersonal({
    required String fullName,
    required String? phoneNumber,
    required String? dateOfBirthIso,
    required String nationality,
    required String documentType,
    required String idNumber,
    required String profilePhotoUrl,
  }) async {
    final userId = _requireUserId();
    await _dio.put(
      '/profile/personal',
      data: {
        'userId': userId,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'dateOfBirth': dateOfBirthIso,
        'nationality': nationality,
        'documentType': documentType,
        'idNumber': idNumber,
        'profilePhotoUrl': profilePhotoUrl,
      },
    );
  }

  Future<void> updateSettings({required String preferredLanguage, required String preferredTheme}) async {
    final userId = _requireUserId();
    await _dio.put(
      '/profile/settings',
      data: {
        'userId': userId,
        'preferredLanguage': preferredLanguage,
        'preferredTheme': preferredTheme,
      },
    );
  }

  Future<void> upsertPaymentMethod({
    int? paymentMethodId,
    required String type,
    required String maskedNumber,
    required bool isDefault,
  }) async {
    final userId = _requireUserId();
    await _dio.post(
      '/profile/payment-methods',
      data: {
        'userId': userId,
        'paymentMethodId': paymentMethodId,
        'type': type,
        'maskedNumber': maskedNumber,
        'isDefault': isDefault,
      },
    );
  }

  Future<void> upsertLinkedBankAccount({
    int? linkedBankAccountId,
    required String bankName,
    required String ibanMasked,
    required bool isVerified,
  }) async {
    final userId = _requireUserId();
    await _dio.post(
      '/profile/linked-bank-accounts',
      data: {
        'userId': userId,
        'linkedBankAccountId': linkedBankAccountId,
        'bankName': bankName,
        'ibanMasked': ibanMasked,
        'isVerified': isVerified,
      },
    );
  }

  int _requireUserId() {
    final userId = AuthSessionStore.userId;
    if (userId == null) {
      throw Exception('No logged-in user. Please login first.');
    }
    return userId;
  }
}

class ProfileRemoteModel {
  ProfileRemoteModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.nationality,
    required this.documentType,
    required this.idNumber,
    required this.profilePhotoUrl,
    required this.preferredLanguage,
    required this.preferredTheme,
    required this.paymentMethods,
    required this.linkedBankAccounts,
  });

  final int userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String nationality;
  final String documentType;
  final String idNumber;
  final String profilePhotoUrl;
  final String preferredLanguage;
  final String preferredTheme;
  final List<PaymentMethodRemoteModel> paymentMethods;
  final List<LinkedBankAccountRemoteModel> linkedBankAccounts;

  factory ProfileRemoteModel.fromJson(Map<String, dynamic> json) {
    return ProfileRemoteModel(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      fullName: (json['fullName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phoneNumber: json['phoneNumber'] as String?,
      dateOfBirth: json['dateOfBirth']?.toString(),
      nationality: (json['nationality'] ?? '') as String,
      documentType: (json['documentType'] ?? '') as String,
      idNumber: (json['idNumber'] ?? '') as String,
      profilePhotoUrl: (json['profilePhotoUrl'] ?? '') as String,
      preferredLanguage: (json['preferredLanguage'] ?? 'en') as String,
      preferredTheme: (json['preferredTheme'] ?? 'light') as String,
      paymentMethods: (json['paymentMethods'] as List<dynamic>? ?? [])
          .map((item) => PaymentMethodRemoteModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      linkedBankAccounts: (json['linkedBankAccounts'] as List<dynamic>? ?? [])
          .map((item) => LinkedBankAccountRemoteModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PaymentMethodRemoteModel {
  PaymentMethodRemoteModel({
    required this.id,
    required this.type,
    required this.maskedNumber,
    required this.isDefault,
  });

  final int id;
  final String type;
  final String maskedNumber;
  final bool isDefault;

  factory PaymentMethodRemoteModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodRemoteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: (json['type'] ?? '') as String,
      maskedNumber: (json['maskedNumber'] ?? '') as String,
      isDefault: (json['isDefault'] ?? false) as bool,
    );
  }
}

class LinkedBankAccountRemoteModel {
  LinkedBankAccountRemoteModel({
    required this.id,
    required this.bankName,
    required this.ibanMasked,
    required this.isVerified,
  });

  final int id;
  final String bankName;
  final String ibanMasked;
  final bool isVerified;

  factory LinkedBankAccountRemoteModel.fromJson(Map<String, dynamic> json) {
    return LinkedBankAccountRemoteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bankName: (json['bankName'] ?? '') as String,
      ibanMasked: (json['ibanMasked'] ?? '') as String,
      isVerified: (json['isVerified'] ?? false) as bool,
    );
  }
}
