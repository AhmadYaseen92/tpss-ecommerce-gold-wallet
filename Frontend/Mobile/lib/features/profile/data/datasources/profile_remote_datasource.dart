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
    required String email,
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
        'email': email,
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

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final userId = _requireUserId();
    await _dio.put(
      '/profile/password',
      data: {
        'userId': userId,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> upsertPaymentMethod({
    int? paymentMethodId,
    required String type,
    required String maskedNumber,
    required String holderName,
    required String expiry,
    required String detailsJson,
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
        'holderName': holderName,
        'expiry': expiry,
        'detailsJson': detailsJson,
        'isDefault': isDefault,
      },
    );
  }

  Future<void> upsertLinkedBankAccount({
    int? linkedBankAccountId,
    required String bankName,
    required String ibanMasked,
    required bool isVerified,
    required bool isDefault,
    required String accountHolderName,
    required String accountNumber,
    required String swiftCode,
    required String branchName,
    required String branchAddress,
    required String country,
    required String city,
    required String currency,
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
        'isDefault': isDefault,
        'accountHolderName': accountHolderName,
        'accountNumber': accountNumber,
        'swiftCode': swiftCode,
        'branchName': branchName,
        'branchAddress': branchAddress,
        'country': country,
        'city': city,
        'currency': currency,
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
    required this.holderName,
    required this.expiry,
    required this.detailsJson,
  });

  final int id;
  final String type;
  final String maskedNumber;
  final bool isDefault;
  final String holderName;
  final String expiry;
  final String detailsJson;

  factory PaymentMethodRemoteModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodRemoteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: (json['type'] ?? '') as String,
      maskedNumber: (json['maskedNumber'] ?? '') as String,
      isDefault: (json['isDefault'] ?? false) as bool,
      holderName: (json['holderName'] ?? '') as String,
      expiry: (json['expiry'] ?? '') as String,
      detailsJson: (json['detailsJson'] ?? '') as String,
    );
  }
}

class LinkedBankAccountRemoteModel {
  LinkedBankAccountRemoteModel({
    required this.id,
    required this.bankName,
    required this.ibanMasked,
    required this.isVerified,
    required this.isDefault,
    required this.accountHolderName,
    required this.accountNumber,
    required this.swiftCode,
    required this.branchName,
    required this.branchAddress,
    required this.country,
    required this.city,
    required this.currency,
  });

  final int id;
  final String bankName;
  final String ibanMasked;
  final bool isVerified;
  final bool isDefault;
  final String accountHolderName;
  final String accountNumber;
  final String swiftCode;
  final String branchName;
  final String branchAddress;
  final String country;
  final String city;
  final String currency;

  factory LinkedBankAccountRemoteModel.fromJson(Map<String, dynamic> json) {
    return LinkedBankAccountRemoteModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bankName: (json['bankName'] ?? '') as String,
      ibanMasked: (json['ibanMasked'] ?? '') as String,
      isVerified: (json['isVerified'] ?? false) as bool,
      isDefault: (json['isDefault'] ?? false) as bool,
      accountHolderName: (json['accountHolderName'] ?? '') as String,
      accountNumber: (json['accountNumber'] ?? '') as String,
      swiftCode: (json['swiftCode'] ?? '') as String,
      branchName: (json['branchName'] ?? '') as String,
      branchAddress: (json['branchAddress'] ?? '') as String,
      country: (json['country'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      currency: (json['currency'] ?? '') as String,
    );
  }
}
