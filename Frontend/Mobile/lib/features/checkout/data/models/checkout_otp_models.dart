class CheckoutOtpDispatchModel {
  const CheckoutOtpDispatchModel({
    required this.otpRequestId,
    required this.nextResendAtUtc,
  });

  final String otpRequestId;
  final DateTime? nextResendAtUtc;

  factory CheckoutOtpDispatchModel.fromJson(Map<String, dynamic> json) {
    return CheckoutOtpDispatchModel(
      otpRequestId: (json['otpRequestId'] ?? '').toString(),
      nextResendAtUtc: DateTime.tryParse((json['nextResendAtUtc'] ?? '').toString()),
    );
  }
}

class CheckoutOtpVerifyModel {
  const CheckoutOtpVerifyModel({
    required this.otpRequestId,
    required this.verificationToken,
  });

  final String otpRequestId;
  final String verificationToken;

  factory CheckoutOtpVerifyModel.fromJson(Map<String, dynamic> json) {
    return CheckoutOtpVerifyModel(
      otpRequestId: (json['otpRequestId'] ?? '').toString(),
      verificationToken: (json['verificationToken'] ?? '').toString(),
    );
  }
}
