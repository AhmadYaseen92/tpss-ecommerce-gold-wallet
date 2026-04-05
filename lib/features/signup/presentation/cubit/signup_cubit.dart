import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(SignupInitial());

  int currentStep = 1;

  // Step 1 fields
  String firstName = '';
  String middleName = '';
  String lastName = '';
  String email = '';
  String phoneCode = '+962';
  String phoneNumber = '';
  DateTime? dateOfBirth;

  // Step 2 fields
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
    emit(SignupPasswordStrengthChanged(
      strength: result.strength,
      strengthLabel: result.label,
    ));
  }

  void updateConfirmPassword(String value) => confirmPassword = value;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    emit(SignupPasswordVisibilityChanged(
      obscurePassword: obscurePassword,
      obscureConfirm: obscureConfirm,
    ));
  }

  void toggleConfirmVisibility() {
    obscureConfirm = !obscureConfirm;
    emit(SignupPasswordVisibilityChanged(
      obscurePassword: obscurePassword,
      obscureConfirm: obscureConfirm,
    ));
  }

  void toggleTerms(bool value) {
    termsAgreed = value;
    emit(SignupTermsChanged(agreed: value));
  }

    calculateStrength(String password) {
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

  void signup() async {
    if (!termsAgreed) {
      emit(SignupError('Please agree to the Terms & Conditions.'));
      return;
    }
    emit(SignupLoading());
    try {
      await Future.delayed(const Duration(seconds: 2));
      emit(SignupSuccess());
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
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryColor,
        ),
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

}
