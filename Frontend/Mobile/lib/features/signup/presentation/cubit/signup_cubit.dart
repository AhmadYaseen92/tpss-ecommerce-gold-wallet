import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/network/api_error_parser.dart';
import 'package:tpss_ecommerce_gold_wallet/features/auth/domain/usecases/register_usecase.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit({required RegisterUseCase registerUseCase})
      : _registerUseCase = registerUseCase,
        super(SignupInitial());

  final RegisterUseCase _registerUseCase;

  int currentStep = 1;
  void goToStep2() { currentStep = 2; emit(SignupStepChanged(step: 2)); }
  void goToStep1() { currentStep = 1; emit(SignupStepChanged(step: 1)); }

  String firstName = '';
  String middleName = '';
  String lastName = '';
  String email = '';
  String phoneCode = '+962';
  String phoneNumber = '';
  DateTime? dateOfBirth;

  void updateFirstName(String value) => firstName = value;
  void updateMiddleName(String value) => middleName = value;
  void updateLastName(String value) => lastName = value;
  void updateEmail(String value) => email = value;
  void updatePhoneCode(String value) { phoneCode = value; emit(SignupPhoneCodeChanged(phoneCode: value)); }
  void updatePhoneNumber(String value) => phoneNumber = value;
  void updateDateOfBirth(DateTime value) { dateOfBirth = value; emit(SignupDateOfBirthChanged(dateOfBirth: value)); }

  String nationality = 'Jordanian';
  String documentType = 'National ID';
  String marketType = 'UAE';
  String idNumber = '';
  String password = '';
  String confirmPassword = '';
  bool termsAgreed = false;

  void updateNationality(String value) { nationality = value; emit(SignupNationalityChanged(nationality: value)); }
  void updateDocumentType(String value) { documentType = value; emit(SignupDocumentTypeChanged(documentType: value)); }
  void updateMarketType(String value) { marketType = value; emit(SignupStepChanged(step: currentStep)); }
  void updateIdNumber(String value) { idNumber = value; }
  void updatePassword(String value) { password = value; final result = calculateStrength(value); emit(SignupPasswordStrengthChanged(strength: result.strength, strengthLabel: result.label)); }
  void updateConfirmPassword(String value) { confirmPassword = value; }
  void toggleTerms(bool value) { termsAgreed = value; emit(SignupTermsChanged(agreed: value)); }

  bool obscurePassword = true;
  bool obscureConfirm = true;
  void togglePasswordVisibility() { obscurePassword = !obscurePassword; emit(SignupPasswordVisibilityChanged(obscurePassword: obscurePassword, obscureConfirm: obscureConfirm)); }
  void toggleConfirmVisibility() { obscureConfirm = !obscureConfirm; emit(SignupPasswordVisibilityChanged(obscurePassword: obscurePassword, obscureConfirm: obscureConfirm)); }

  ({double strength, String label}) calculateStrength(String password) {
    if (password.isEmpty) return (strength: 0.0, label: '');
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(password)) score++;
    return switch (score) { 0 || 1 => (strength: 0.25, label: 'Weak'), 2 => (strength: 0.5, label: 'Medium'), 3 => (strength: 0.75, label: 'Strong'), 4 => (strength: 1.0, label: 'Very Strong'), _ => (strength: 0.0, label: '') };
  }

  Future<void> signup() async {
    if (!termsAgreed) { emit(SignupError('Please agree to the Terms & Conditions.')); return; }
    emit(SignupLoading());
    try {
      final message = await _registerUseCase(
        firstName: firstName,middleName: middleName,lastName: lastName,email: email,phoneNumber: '$phoneCode$phoneNumber',password: password,
        dateOfBirth: dateOfBirth?.toIso8601String().split('T').first,nationality: nationality,documentType: documentType,idNumber: idNumber,profilePhotoUrl: '',preferredLanguage: 'en',preferredTheme: 'light',marketType: marketType,sellerId: 0,
      );
      emit(SignupSuccess(message));
    } on DioException catch (e) {
      emit(SignupError(ApiErrorParser.friendlyMessage(e)));
    } catch (e) {
      emit(SignupError('Sign up failed. Please try again later.'));
    }
  }

  void onSubmit(GlobalKey<FormState> formKey) { if (formKey.currentState?.validate() ?? false) { signup(); } }

  void pickDate(BuildContext context) async {
    final picked = await showDatePicker(context: context, initialDate: dateOfBirth ?? DateTime(2000), firstDate: DateTime(1900), lastDate: DateTime.now());
    if (picked != null) updateDateOfBirth(picked);
  }
}
