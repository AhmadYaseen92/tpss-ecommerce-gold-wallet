import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

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

  void login({required String identifier, required String password}) async {
    emit(LoginLoading());
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (identifier.isEmpty || password.isEmpty) {
        emit(LoginError('Please fill in all fields.'));
        return;
      }
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginError('Login failed: $e'));
    }
  }

  void loginWithFaceId() async {
    emit(LoginLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      // TODO: Integrate biometric authentication
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginError('Face ID authentication failed.'));
    }
  }

  void loginWithFingerprint() async {
    emit(LoginLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      // TODO: Integrate biometric authentication
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginError('Fingerprint authentication failed.'));
    }
  }

    void onLoginPressed(GlobalKey<FormState> formKey) {
    if (formKey.currentState?.validate() ?? false) {
      login(identifier: identifier, password: password);
    }
  }

}
