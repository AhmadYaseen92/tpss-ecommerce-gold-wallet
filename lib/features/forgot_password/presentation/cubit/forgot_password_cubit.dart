import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  int currentStep = 1;

  // Step 1
  String contact = '';
  String deliveryMethod = 'email';

  // Step 2
  String otp = '';
  int secondsRemaining = 59;
  Timer? timer;
  List<String> otpDigits = List.filled(6, '');

  // Step 3
  String newPassword = '';
  String confirmPassword = '';
  bool obscureNew = true;
  bool obscureConfirm = true;
  double passwordStrength = 0.0;
  String passwordStrengthLabel = '';

  bool get hasMinChars => newPassword.length >= 8;
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(newPassword);
  bool get hasSpecialChar => RegExp(r'[!@#\$%^&*]').hasMatch(newPassword);
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(newPassword);

  void updateContact(String value) => contact = value;

  void updateDeliveryMethod(String value) {
    deliveryMethod = value;
    emit(ForgotPasswordDeliveryMethodChanged(method: value));
  }

  void sendOtp() async {
    if (contact.trim().isEmpty) {
      emit(ForgotPasswordError('Please enter your email or phone number.'));
      return;
    }
    emit(ForgotPasswordLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      currentStep = 2;
      startTimer();
      emit(ForgotPasswordStepChanged(step: 2));
    } catch (e) {
      emit(ForgotPasswordError('Failed to send OTP. Please try again.'));
    }
  }

  void startTimer() {
    secondsRemaining = 59;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        secondsRemaining--;
        emit(ForgotPasswordTimerTick(secondsRemaining: secondsRemaining));
      } else {
        timer.cancel();
      }
    });
  }

  void resendOtp() {
    startTimer();
    emit(ForgotPasswordTimerTick(secondsRemaining: 59));
  }

  void updateOtp(String value) {
    otp = value;
    for (int i = 0; i < otpDigits.length; i++) {
      otpDigits[i] = i < value.length ? value[i] : '';
    }
    emit(ForgotPasswordOtpChanged(otp: value));
  }

  void verifyOtp() async {
    if (otp.length < 6) {
      emit(ForgotPasswordError('Please enter the complete 6-digit code.'));
      return;
    }
    emit(ForgotPasswordLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      timer?.cancel();
      currentStep = 3;
      emit(ForgotPasswordStepChanged(step: 3));
    } catch (e) {
      emit(ForgotPasswordError('Invalid OTP. Please try again.'));
    }
  }

  void updateNewPassword(String value) {
    newPassword = value;
    final result = calculateStrength(value);
    passwordStrength = result.strength;
    passwordStrengthLabel = result.label;
    emit(
      ForgotPasswordPasswordVisibilityChanged(
        obscureNew: obscureNew,
        obscureConfirm: obscureConfirm,
      ),
    );
  }

  void updateConfirmPassword(String value) => confirmPassword = value;

  void toggleNewPasswordVisibility() {
    obscureNew = !obscureNew;
    emit(
      ForgotPasswordPasswordVisibilityChanged(
        obscureNew: obscureNew,
        obscureConfirm: obscureConfirm,
      ),
    );
  }

  void toggleConfirmVisibility() {
    obscureConfirm = !obscureConfirm;
    emit(
      ForgotPasswordPasswordVisibilityChanged(
        obscureNew: obscureNew,
        obscureConfirm: obscureConfirm,
      ),
    );
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

  void goBack() {
    if (currentStep > 1) {
      currentStep--;
      emit(ForgotPasswordStepChanged(step: currentStep));
    }
  }

  void resetPassword(String password, String confirm) async {
    if (password.isEmpty) {
      emit(ForgotPasswordError('Please enter a new password.'));
      return;
    }
    if (password.length < 8) {
      emit(ForgotPasswordError('Password must be at least 8 characters.'));
      return;
    }
    if (password != confirm) {
      emit(ForgotPasswordError('Passwords do not match.'));
      return;
    }
    emit(ForgotPasswordLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(ForgotPasswordSuccess());
    } catch (e) {
      emit(ForgotPasswordError('Failed to reset password. Please try again.'));
    }
  }

  String get maskedTarget {
    if (deliveryMethod == 'email') {
      return 'reg***@email.com';
    }
    return '+962 **** **99';
  }

  String formatTimer(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }
}
