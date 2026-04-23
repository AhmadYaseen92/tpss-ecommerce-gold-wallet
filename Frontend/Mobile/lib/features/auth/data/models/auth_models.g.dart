// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

LoginRequestModel _$LoginRequestModelFromJson(Map<String, dynamic> json) =>
    LoginRequestModel(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestModelToJson(LoginRequestModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

RegisterRequestModel _$RegisterRequestModelFromJson(Map<String, dynamic> json) =>
    RegisterRequestModel(
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      password: json['password'] as String,
      dateOfBirth: json['dateOfBirth'] as String?,
      nationality: json['nationality'] as String?,
      documentType: json['documentType'] as String?,
      idNumber: json['idNumber'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      preferredLanguage: json['preferredLanguage'] as String?,
      preferredTheme: json['preferredTheme'] as String?,
      sellerId: (json['sellerId'] as num?)?.toInt() ?? 0,
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiresAtUtc: DateTime.parse(json['refreshTokenExpiresAtUtc'] as String),
    );

Map<String, dynamic> _$RegisterRequestModelToJson(
  RegisterRequestModel instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'middleName': instance.middleName,
  'lastName': instance.lastName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'password': instance.password,
  'dateOfBirth': instance.dateOfBirth,
  'nationality': instance.nationality,
  'documentType': instance.documentType,
  'idNumber': instance.idNumber,
  'profilePhotoUrl': instance.profilePhotoUrl,
  'preferredLanguage': instance.preferredLanguage,
  'preferredTheme': instance.preferredTheme,
  'sellerId': instance.sellerId,
};

LoginResponseModel _$LoginResponseModelFromJson(Map<String, dynamic> json) =>
    LoginResponseModel(
      accessToken: json['accessToken'] as String,
      expiresAtUtc: DateTime.parse(json['expiresAtUtc'] as String),
      role: json['role'] as String,
      userId: (json['userId'] as num).toInt(),
      sellerId: (json['sellerId'] as num?)?.toInt() ?? 0,
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiresAtUtc: DateTime.parse(json['refreshTokenExpiresAtUtc'] as String),
    );

Map<String, dynamic> _$LoginResponseModelToJson(LoginResponseModel instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'expiresAtUtc': instance.expiresAtUtc.toIso8601String(),
      'role': instance.role,
      'userId': instance.userId,
      'sellerId': instance.sellerId,
      'refreshToken': instance.refreshToken,
      'refreshTokenExpiresAtUtc': instance.refreshTokenExpiresAtUtc.toIso8601String(),
    };

RefreshTokenRequestModel _$RefreshTokenRequestModelFromJson(
  Map<String, dynamic> json,
) => RefreshTokenRequestModel(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$RefreshTokenRequestModelToJson(
  RefreshTokenRequestModel instance,
) => <String, dynamic>{'refreshToken': instance.refreshToken};

ApiEnvelope<T> _$ApiEnvelopeFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => ApiEnvelope<T>(
  success: json['success'] as bool,
  statusCode: (json['statusCode'] as num).toInt(),
  message: json['message'] as String,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  errors: (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$ApiEnvelopeToJson<T>(
  ApiEnvelope<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'errors': instance.errors,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
