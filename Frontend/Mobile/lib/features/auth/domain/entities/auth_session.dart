class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.expiresAtUtc,
    required this.role,
    required this.userId,
  });

  final String accessToken;
  final DateTime expiresAtUtc;
  final String role;
  final int userId;
}
