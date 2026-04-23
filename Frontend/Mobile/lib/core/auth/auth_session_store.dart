import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSessionStore {
  AuthSessionStore._();

  static const _secure = FlutterSecureStorage();

  static const _kAccessToken = 'auth_access_token';
  static const _kAccessTokenExp = 'auth_access_token_exp';
  static const _kRefreshToken = 'auth_refresh_token';
  static const _kRefreshTokenExp = 'auth_refresh_token_exp';
  static const _kUserId = 'auth_user_id';
  static const _kSellerId = 'auth_seller_id';

  static const _kQuickUnlockEnabled = 'security_quick_unlock_enabled';
  static const _kBiometricEnabled = 'security_biometric_enabled';
  static const _kPinHash = 'security_pin_hash';
  static const _kPinSalt = 'security_pin_salt';
  static const _kPinSetupComplete = 'security_pin_setup_complete';
  static const _kLastInactiveAt = 'security_last_inactive_at';
  static const _kLocked = 'security_locked';

  static String? accessToken;
  static String? refreshToken;
  static DateTime? accessTokenExpiresAtUtc;
  static DateTime? refreshTokenExpiresAtUtc;
  static int? userId;
  static int? sellerId;

  static bool quickUnlockEnabled = false;
  static bool biometricEnabled = false;
  static bool pinSetupComplete = false;

  static Future<void> hydrate() async {
    accessToken = await _secure.read(key: _kAccessToken);
    refreshToken = await _secure.read(key: _kRefreshToken);
    accessTokenExpiresAtUtc = _tryParseDate(await _secure.read(key: _kAccessTokenExp));
    refreshTokenExpiresAtUtc = _tryParseDate(await _secure.read(key: _kRefreshTokenExp));
    userId = int.tryParse(await _secure.read(key: _kUserId) ?? '');
    sellerId = int.tryParse(await _secure.read(key: _kSellerId) ?? '');
    quickUnlockEnabled = (await _secure.read(key: _kQuickUnlockEnabled)) == '1';
    biometricEnabled = (await _secure.read(key: _kBiometricEnabled)) == '1';
    pinSetupComplete = (await _secure.read(key: _kPinSetupComplete)) == '1';
  }

  static bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  static Future<void> setSession({
    required String token,
    required DateTime tokenExpiresAtUtc,
    required String newRefreshToken,
    required DateTime newRefreshTokenExpiresAtUtc,
    required int uid,
    required int sid,
  }) async {
    accessToken = token;
    refreshToken = newRefreshToken;
    accessTokenExpiresAtUtc = tokenExpiresAtUtc.toUtc();
    refreshTokenExpiresAtUtc = newRefreshTokenExpiresAtUtc.toUtc();
    userId = uid;
    sellerId = sid;

    await _secure.write(key: _kAccessToken, value: token);
    await _secure.write(key: _kRefreshToken, value: newRefreshToken);
    await _secure.write(key: _kAccessTokenExp, value: tokenExpiresAtUtc.toUtc().toIso8601String());
    await _secure.write(key: _kRefreshTokenExp, value: newRefreshTokenExpiresAtUtc.toUtc().toIso8601String());
    await _secure.write(key: _kUserId, value: '$uid');
    await _secure.write(key: _kSellerId, value: '$sid');
  }

  static Future<void> clearAll() async {
    accessToken = null;
    refreshToken = null;
    accessTokenExpiresAtUtc = null;
    refreshTokenExpiresAtUtc = null;
    userId = null;
    sellerId = null;
    quickUnlockEnabled = false;
    biometricEnabled = false;
    pinSetupComplete = false;
    await _secure.deleteAll();
  }

  static Future<void> setQuickUnlockEnabled(bool enabled) async {
    quickUnlockEnabled = enabled;
    await _secure.write(key: _kQuickUnlockEnabled, value: enabled ? '1' : '0');
    if (!enabled) {
      await setLocked(false);
    }
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    biometricEnabled = enabled;
    await _secure.write(key: _kBiometricEnabled, value: enabled ? '1' : '0');
  }

  static Future<void> setPin(String pin) async {
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = sha256.convert(utf8.encode('$salt:$pin')).toString();
    await _secure.write(key: _kPinSalt, value: salt);
    await _secure.write(key: _kPinHash, value: hash);
    pinSetupComplete = true;
    await _secure.write(key: _kPinSetupComplete, value: '1');
  }

  static Future<void> removePin() async {
    pinSetupComplete = false;
    await _secure.delete(key: _kPinSalt);
    await _secure.delete(key: _kPinHash);
    await _secure.write(key: _kPinSetupComplete, value: '0');
  }

  static Future<bool> verifyPin(String pin) async {
    final salt = await _secure.read(key: _kPinSalt);
    final hash = await _secure.read(key: _kPinHash);
    if (salt == null || hash == null) return false;
    final candidate = sha256.convert(utf8.encode('$salt:$pin')).toString();
    return candidate == hash;
  }

  static Future<void> markInactiveNow() async {
    await _secure.write(key: _kLastInactiveAt, value: DateTime.now().toUtc().toIso8601String());
  }

  static Future<bool> shouldLockForInactivity({Duration timeout = const Duration(minutes: 5)}) async {
    if (!quickUnlockEnabled) return false;
    final raw = await _secure.read(key: _kLastInactiveAt);
    final at = _tryParseDate(raw);
    if (at == null) return false;
    return DateTime.now().toUtc().difference(at) >= timeout;
  }

  static Future<void> setLocked(bool locked) async {
    await _secure.write(key: _kLocked, value: locked ? '1' : '0');
  }

  static Future<bool> isLocked() async => (await _secure.read(key: _kLocked)) == '1';

  static DateTime? _tryParseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }
}
