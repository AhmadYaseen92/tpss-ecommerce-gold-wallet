import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/api_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/usecases/login_usecase.dart';

part 'login_state.dart';

enum BiometricTypeUI { faceId, fingerprint, none }

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required LoginUseCase loginUseCase, required Dio dio})
    : _loginUseCase = loginUseCase,
      _dio = dio,
      super(LoginInitial()) {
    detectBiometricType();
  }
  final LoginUseCase _loginUseCase;
  final Dio _dio;
  final LocalAuthentication _auth = LocalAuthentication();
  BiometricTypeUI biometricType = BiometricTypeUI.none;

  bool rememberMe = false;
  bool obscurePassword = true;
  String identifier = 'investor@goldwallet.com';
  String password = 'Password@123';

  String get currentBaseUrl => ApiConfig.baseUrl;
  int get currentTimeoutSeconds => ApiConfig.timeoutSeconds;

  Future<void> detectBiometricType() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      debugPrint('🔐 Biometric Detection: canCheck=$canCheck');

      if (!canCheck) {
        biometricType = BiometricTypeUI.none;
        debugPrint('❌ Cannot check biometrics on this device');
        emit(LoginBiometricDetected(biometricType));
        return;
      }

      final list = await _auth.getAvailableBiometrics();
      debugPrint('📱 Available biometrics: $list');

      if (list.contains(BiometricType.face)) {
        biometricType = BiometricTypeUI.faceId;
        debugPrint('✅ Face ID detected');
      } else if (list.contains(BiometricType.fingerprint)) {
        biometricType = BiometricTypeUI.fingerprint;
        debugPrint('✅ Fingerprint detected');
      } else {
        biometricType = BiometricTypeUI.none;
        debugPrint('❌ No biometrics found');
      }

      emit(LoginBiometricDetected(biometricType));
    } catch (e) {
      biometricType = BiometricTypeUI.none;
      debugPrint('⚠️ Biometric detection failed: $e');
      emit(LoginBiometricDetected(biometricType));
    }
  }

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

  Future<bool> _canUseBiometrics() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> _authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> loginWithFaceId() async {
    await _handleBiometric("Face ID Login");
  }

  Future<void> loginWithFingerprint() async {
    await _handleBiometric("Fingerprint Login");
  }

  Future<void> _handleBiometric(String reason) async {
    emit(LoginLoading());

    final supported = await _canUseBiometrics();

    if (!supported) {
      emit(LoginError("Biometrics not supported on this device"));
      return;
    }

    final success = await _authenticate(reason);

    if (success) {
      emit(LoginSuccess());
    } else {
      emit(LoginError("Authentication failed"));
    }
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

      final session = await _loginUseCase(
        email: identifier,
        password: password,
      );
      await AuthSessionStore.setSession(
        token: session.accessToken,
        tokenExpiresAtUtc: session.expiresAtUtc,
        newRefreshToken: session.refreshToken,
        newRefreshTokenExpiresAtUtc: session.refreshTokenExpiresAtUtc,
        uid: session.userId,
        sid: session.sellerId,
      );
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
      emit(LoginServerCheckResult(success: false, message: _extractMessage(e)));
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
