class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.expiresAtUtc,
    required this.role,
    required this.userId,
    required this.sellerId,
    required this.refreshToken,
    required this.refreshTokenExpiresAtUtc,
  });

  final String accessToken;
  final DateTime expiresAtUtc;
  final String role;
  final int userId;
  final int sellerId;
  final String refreshToken;
  final DateTime refreshTokenExpiresAtUtc;
}
