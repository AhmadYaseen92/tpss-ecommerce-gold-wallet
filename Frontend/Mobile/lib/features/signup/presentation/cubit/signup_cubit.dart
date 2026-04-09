import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/usecases/register_usecase.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit({required RegisterUseCase registerUseCase})
    : _registerUseCase = registerUseCase,
      super(SignupInitial());

  final RegisterUseCase _registerUseCase;

  int currentStep = 1;

  String firstName = '';
  String middleName = '';
  String lastName = '';
  String email = '';
  String phoneCode = '+962';
  String phoneNumber = '';
  DateTime? dateOfBirth;

  String nationality = 'Jordanian';
  String documentType = 'National ID';
  String idNumber = '';
  String password = '';
  String confirmPassword = '';
  bool termsAgreed = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  double passwordStrength = 0.0;
  String passwordStrengthLabel = '';

  void goToStep2() {
    currentStep = 2;
    emit(SignupStepChanged(step: 2));
  }

  void goToStep1() {
    currentStep = 1;
    emit(SignupStepChanged(step: 1));
  }

  void updateFirstName(String value) => firstName = value;
  void updateMiddleName(String value) => middleName = value;
  void updateLastName(String value) => lastName = value;
  void updateEmail(String value) => email = value;

  void updatePhoneCode(String value) {
    phoneCode = value;
    emit(SignupPhoneCodeChanged(phoneCode: value));
  }

  void updatePhoneNumber(String value) => phoneNumber = value;

  void updateDateOfBirth(DateTime value) {
    dateOfBirth = value;
    emit(SignupDateOfBirthChanged(dateOfBirth: value));
  }

  void updateNationality(String value) {
    nationality = value;
    emit(SignupNationalityChanged(nationality: value));
  }

  void updateDocumentType(String value) {
    documentType = value;
    emit(SignupDocumentTypeChanged(documentType: value));
  }

  void updateIdNumber(String value) => idNumber = value;

  void updatePassword(String value) {
    password = value;
    final result = calculateStrength(value);
    passwordStrength = result.strength;
    passwordStrengthLabel = result.label;
    emit(
      SignupPasswordStrengthChanged(
        strength: result.strength,
        strengthLabel: result.label,
      ),
    );
  }

  void updateConfirmPassword(String value) => confirmPassword = value;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    emit(
      SignupPasswordVisibilityChanged(
        obscurePassword: obscurePassword,
        obscureConfirm: obscureConfirm,
      ),
    );
  }

  void toggleConfirmVisibility() {
    obscureConfirm = !obscureConfirm;
    emit(
      SignupPasswordVisibilityChanged(
        obscurePassword: obscurePassword,
        obscureConfirm: obscureConfirm,
      ),
    );
  }

  void toggleTerms(bool value) {
    termsAgreed = value;
    emit(SignupTermsChanged(agreed: value));
  }

  ({double strength, String label}) calculateStrength(String password) {
    if (password.isEmpty) return (strength: 0.0, label: '');
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(password)) score++;
    if (score <= 1) return (strength: 0.25, label: 'Weak');
    if (score == 2) return (strength: 0.5, label: 'Medium');
    if (score == 3) return (strength: 0.75, label: 'Strong');
    return (strength: 1.0, label: 'Very Strong');
  }

  Future<void> signup() async {
    if (!termsAgreed) {
      emit(SignupError('Please agree to the Terms & Conditions.'));
      return;
    }

    emit(SignupLoading());
    try {
      final message = await _registerUseCase(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: '$phoneCode$phoneNumber',
        password: password,
        dateOfBirth: dateOfBirth?.toIso8601String().split('T').first,
        nationality: nationality,
        preferredLanguage: 'en',
        preferredTheme: 'light',
      );
      emit(SignupSuccess(message));
    } on DioException catch (e) {
      emit(SignupError(_extractMessage(e)));
    } catch (e) {
      emit(SignupError('Sign up failed: $e'));
    }
  }

  void pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryColor),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      updateDateOfBirth(picked);
    }
  }

  void onSubmit(GlobalKey<FormState> formKey) {
    if (formKey.currentState?.validate() ?? false) {
      signup();
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

    return 'Signup failed. Ensure backend has /auth/register endpoint.';
  }
}
