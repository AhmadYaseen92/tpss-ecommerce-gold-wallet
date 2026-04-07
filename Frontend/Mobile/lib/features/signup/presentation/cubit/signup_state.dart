part of 'signup_cubit.dart';

class SignupState {}

final class SignupInitial extends SignupState {}

final class SignupLoading extends SignupState {}

final class SignupSuccess extends SignupState {}

final class SignupError extends SignupState {
  final String message;
  SignupError(this.message);
}

final class SignupStepChanged extends SignupState {
  final int step;
  SignupStepChanged({required this.step});
}

final class SignupPasswordVisibilityChanged extends SignupState {
  final bool obscurePassword;
  final bool obscureConfirm;
  SignupPasswordVisibilityChanged({
    required this.obscurePassword,
    required this.obscureConfirm,
  });
}

final class SignupPasswordStrengthChanged extends SignupState {
  final double strength;
  final String strengthLabel;
  SignupPasswordStrengthChanged({
    required this.strength,
    required this.strengthLabel,
  });
}

final class SignupDocumentTypeChanged extends SignupState {
  final String documentType;
  SignupDocumentTypeChanged({required this.documentType});
}

final class SignupTermsChanged extends SignupState {
  final bool agreed;
  SignupTermsChanged({required this.agreed});
}

final class SignupNationalityChanged extends SignupState {
  final String nationality;
  SignupNationalityChanged({required this.nationality});
}

final class SignupPhoneCodeChanged extends SignupState {
  final String phoneCode;
  SignupPhoneCodeChanged({required this.phoneCode});
}

final class SignupDateOfBirthChanged extends SignupState {
  final DateTime dateOfBirth;
  SignupDateOfBirthChanged({required this.dateOfBirth});
}
