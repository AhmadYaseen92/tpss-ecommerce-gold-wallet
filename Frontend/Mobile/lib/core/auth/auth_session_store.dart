class AuthSessionStore {
  AuthSessionStore._();

  static String? accessToken;
  static int? userId;
  static int? sellerId;

  static bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  static void setSession({required String token, required int uid, required int sid}) {
    accessToken = token;
    userId = uid;
    sellerId = sid;
  }

  static void clear() {
    accessToken = null;
    userId = null;
    sellerId = null;
  }
}
