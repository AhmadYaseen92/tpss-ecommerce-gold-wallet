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

  CheckoutOtpRequestContextEntity copyWith({
    int? userId,
    int? productId,
    int? quantity,
    List<int>? productIds,
    bool? forceEmailFallback,
  }) {
    return CheckoutOtpRequestContextEntity(
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      productIds: productIds ?? this.productIds,
      forceEmailFallback: forceEmailFallback ?? this.forceEmailFallback,
    );
  }
}

class CheckoutOtpSessionEntity {
  const CheckoutOtpSessionEntity({
    required this.otpRequestId,
    this.nextResendAtUtc,
  });

  final String otpRequestId;
  final DateTime? nextResendAtUtc;
}

class CheckoutOtpVerificationEntity {
  const CheckoutOtpVerificationEntity({
    required this.otpRequestId,
    required this.verificationToken,
  });

  final String otpRequestId;
  final String verificationToken;
}
