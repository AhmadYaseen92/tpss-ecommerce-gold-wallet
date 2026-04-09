import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/usecases/login_usecase.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required LoginUseCase loginUseCase})
    : _loginUseCase = loginUseCase,
      super(LoginInitial());

  final LoginUseCase _loginUseCase;

  bool rememberMe = false;
  bool obscurePassword = true;
  String identifier = '';
  String password = '';

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
