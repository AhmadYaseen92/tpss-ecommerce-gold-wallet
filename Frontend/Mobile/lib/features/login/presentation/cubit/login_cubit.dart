import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/api_config.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/usecases/login_usecase.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required LoginUseCase loginUseCase, required Dio dio})
    : _loginUseCase = loginUseCase,
      _dio = dio,
      super(LoginInitial());

  final LoginUseCase _loginUseCase;
  final Dio _dio;

  bool rememberMe = false;
  bool obscurePassword = true;
  String identifier = 'investor@goldwallet.com';
  String password = 'Password@123';

  String get currentBaseUrl => ApiConfig.baseUrl;
  int get currentTimeoutSeconds => ApiConfig.timeoutSeconds;

  void updateIdentifier(String value) {
    identifier = value;
  }

  void updatePassword(String value) {
    password = value;
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    emit(LoginPasswordVisibilityChanged(obscurePassword: obscurePassword));
  }

  void toggleRememberMe(bool value) {
    rememberMe = value;
    emit(LoginRememberMeChanged(rememberMe: rememberMe));
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    emit(LoginLoading());
    try {
      if (identifier.isEmpty || password.isEmpty) {
        emit(LoginError('Please fill in all fields.'));
        return;
      }

      await _loginUseCase(email: identifier, password: password);
      emit(LoginSuccess());
    } on DioException catch (e) {
      emit(LoginError(_extractMessage(e)));
    } catch (e) {
      emit(LoginError('Login failed: $e'));
    }
  }

  Future<void> checkServerConnection() async {
    try {
      await _dio.get('/auth/ping');
      emit(
        LoginServerCheckResult(
          success: true,
          message: 'Connected successfully to ${ApiConfig.baseUrl}.',
        ),
      );
    } on DioException catch (e) {
      emit(
        LoginServerCheckResult(
          success: false,
          message: _extractMessage(e),
        ),
      );
    }
  }

  void updateServerConfig({
    required String baseUrl,
    required int timeoutSeconds,
  }) {
    InjectionContainer.updateNetworkConfig(
      baseUrl: baseUrl,
      timeoutSeconds: timeoutSeconds,
    );
    emit(
      LoginServerConfigUpdated(
        baseUrl: ApiConfig.baseUrl,
        timeoutSeconds: ApiConfig.timeoutSeconds,
      ),
    );
  }

  Future<void> loginWithFaceId() async {
    emit(LoginError('Biometric login is not connected yet.'));
  }

  Future<void> loginWithFingerprint() async {
    emit(LoginError('Biometric login is not connected yet.'));
  }

  void onLoginPressed(GlobalKey<FormState> formKey) {
    if (formKey.currentState?.validate() ?? false) {
      login(identifier: identifier, password: password);
    }
  }

  String _extractMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout after ${ApiConfig.timeoutSeconds}s. '
          'Check server IP/port, same Wi-Fi network, and firewall settings.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to ${ApiConfig.baseUrl}. '
          'Make sure backend is running and phone can reach your machine.';
    }

    final payload = e.response?.data;
    if (payload is Map<String, dynamic>) {
      final errors = payload['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.first.toString();
      }

      final message = payload['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (e.error is String && (e.error as String).trim().isNotEmpty) {
      return e.error as String;
    }

    return 'Login failed. Please check your credentials and backend URL.';
  }
}
