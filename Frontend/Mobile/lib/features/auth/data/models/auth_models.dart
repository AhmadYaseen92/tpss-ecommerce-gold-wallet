import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequestModel {
  const LoginRequestModel({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}

@JsonSerializable()
class RegisterRequestModel {
  const RegisterRequestModel({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.dateOfBirth,
    this.nationality,
    this.documentType,
    this.idNumber,
    this.profilePhotoUrl,
    this.preferredLanguage,
    this.preferredTheme,
    this.sellerId = 0,
  });

  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String? dateOfBirth;
  final String? nationality;
  final String? documentType;
  final String? idNumber;
  final String? profilePhotoUrl;
  final String? preferredLanguage;
  final String? preferredTheme;
  final int sellerId;

  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);
}

@JsonSerializable()
class LoginResponseModel {
  const LoginResponseModel({
    required this.accessToken,
    required this.expiresAtUtc,
    required this.role,
    required this.userId,
    required this.sellerId,
    required this.refreshToken,
    required this.refreshTokenExpiresAtUtc,
  });

  final String accessToken;
  final DateTime expiresAtUtc;
  final String role;
  final int userId;
  final int sellerId;
  final String refreshToken;
  final DateTime refreshTokenExpiresAtUtc;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final expiresAt = DateTime.tryParse('${json['expiresAtUtc']}') ?? DateTime.now().toUtc();
    final refreshExpiryRaw = json['refreshTokenExpiresAtUtc'];
    final refreshExpiresAt = refreshExpiryRaw == null
        ? expiresAt
        : (DateTime.tryParse('$refreshExpiryRaw') ?? expiresAt);

    return LoginResponseModel(
      accessToken: (json['accessToken'] ?? '').toString(),
      expiresAtUtc: expiresAt,
      role: (json['role'] ?? '').toString(),
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      sellerId: (json['sellerId'] as num?)?.toInt() ?? 0,
      refreshToken: (json['refreshToken'] ?? '').toString(),
      refreshTokenExpiresAtUtc: refreshExpiresAt,
    );
  }
}

@JsonSerializable()
class RefreshTokenRequestModel {
  const RefreshTokenRequestModel({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

@JsonSerializable(genericArgumentFactories: true)
class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
    required this.errors,
  });

  final bool success;
  final int statusCode;
  final String message;
  final T? data;
  final List<String> errors;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final rawErrors = json['errors'];
    return ApiEnvelope<T>(
      success: json['success'] == true,
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
      message: (json['message'] ?? '').toString(),
      data: json['data'] == null ? null : fromJsonT(json['data']),
      errors: rawErrors is List
          ? rawErrors.map((e) => e.toString()).toList()
          : const <String>[],
    );
  }
}
