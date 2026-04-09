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

  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);
}

@JsonSerializable()
class LoginResponseModel {
  const LoginResponseModel({
    required this.accessToken,
    required this.expiresAtUtc,
    required this.role,
    required this.userId,
  });

  final String accessToken;
  final DateTime expiresAtUtc;
  final String role;
  final int userId;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);
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
  ) => _$ApiEnvelopeFromJson(json, fromJsonT);
}
