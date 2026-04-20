class CheckoutOtpRequestContextEntity {
  const CheckoutOtpRequestContextEntity({
    required this.userId,
    this.productId,
    this.quantity,
    this.productIds = const [],
    this.forceEmailFallback = false,
  });

  final int userId;
  final int? productId;
  final int? quantity;
  final List<int> productIds;
  final bool forceEmailFallback;
}

class CheckoutOtpSessionEntity {
  const CheckoutOtpSessionEntity({
    required this.otpRequestId,
  });

  final String otpRequestId;
}

class CheckoutOtpVerificationEntity {
  const CheckoutOtpVerificationEntity({
    required this.otpRequestId,
    required this.verificationToken,
  });

  final String otpRequestId;
  final String verificationToken;
}
