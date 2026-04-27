import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';

class AuthSessionStore {
  AuthSessionStore._();

  static const _secure = FlutterSecureStorage();

  static const _kAccessToken = 'auth_access_token';
  static const _kAccessTokenExp = 'auth_access_token_exp';
  static const _kRefreshToken = 'auth_refresh_token';
  static const _kRefreshTokenExp = 'auth_refresh_token_exp';
  static const _kUserId = 'auth_user_id';
  static const _kSellerId = 'auth_seller_id';

  static const _kAutoLockEnabled = 'security_auto_lock_enabled';
  static const _kOnboardingSeen = 'onboarding_seen';
  static const _kSecuritySetupDone = 'security_setup_done';
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

  static bool autoLockEnabled = true;
  static bool onboardingSeen = false;
  static bool securitySetupDone = false;
  static bool quickUnlockEnabled = false;
  static bool biometricEnabled = false;
  static bool pinSetupComplete = false;

  static bool get hasPin => pinSetupComplete;
  static bool get hasUnlockMethod => biometricEnabled || pinSetupComplete;
  static bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  static Future<void> hydrate() async {
    autoLockEnabled = (await _secure.read(key: _kAutoLockEnabled)) != '0';
    onboardingSeen = (await _secure.read(key: _kOnboardingSeen)) == '1';
    securitySetupDone = (await _secure.read(key: _kSecuritySetupDone)) == '1';
    quickUnlockEnabled = (await _secure.read(key: _kQuickUnlockEnabled)) == '1';
    biometricEnabled = (await _secure.read(key: _kBiometricEnabled)) == '1';
    pinSetupComplete = (await _secure.read(key: _kPinSetupComplete)) == '1';

    accessToken = await _secure.read(key: _kAccessToken);
    refreshToken = await _secure.read(key: _kRefreshToken);
    accessTokenExpiresAtUtc = _tryParseDate(await _secure.read(key: _kAccessTokenExp));
    refreshTokenExpiresAtUtc = _tryParseDate(await _secure.read(key: _kRefreshTokenExp));
    userId = int.tryParse(await _secure.read(key: _kUserId) ?? '');
    sellerId = int.tryParse(await _secure.read(key: _kSellerId) ?? '');

    await _normalizeSecurityState();
  }

  static Future<void> applyAdminUnlockPolicy() async {
    if (!AppReleaseConfig.loginByBiometricEnabled && biometricEnabled) {
      biometricEnabled = false;
      await _secure.write(key: _kBiometricEnabled, value: '0');
    }

    if (!AppReleaseConfig.loginByPinEnabled && pinSetupComplete) {
      pinSetupComplete = false;
      await _secure.delete(key: _kPinSalt);
      await _secure.delete(key: _kPinHash);
      await _secure.write(key: _kPinSetupComplete, value: '0');
    }

    await _normalizeSecurityState();
  }

  static Future<void> setAutoLockEnabled(bool enabled) async {
    autoLockEnabled = enabled;
    await _secure.write(key: _kAutoLockEnabled, value: enabled ? '1' : '0');
    if (!enabled) {
      await setLocked(false);
    }
  }

  static Future<void> setOnboardingSeen(bool seen) async {
    onboardingSeen = seen;
    await _secure.write(key: _kOnboardingSeen, value: seen ? '1' : '0');
  }

  static Future<void> setSecuritySetupDone(bool done) async {
    securitySetupDone = done;
    await _secure.write(key: _kSecuritySetupDone, value: done ? '1' : '0');
  }

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

    await _safeWrite(_kAccessToken, token);
    await _safeWrite(_kRefreshToken, newRefreshToken);
    await _safeWrite(_kAccessTokenExp, tokenExpiresAtUtc.toUtc().toIso8601String());
    await _safeWrite(_kRefreshTokenExp, newRefreshTokenExpiresAtUtc.toUtc().toIso8601String());
    await _safeWrite(_kUserId, '$uid');
    await _safeWrite(_kSellerId, '$sid');
  }

  static Future<void> clearSessionOnly() async {
    accessToken = null;
    refreshToken = null;
    accessTokenExpiresAtUtc = null;
    refreshTokenExpiresAtUtc = null;
    userId = null;
    sellerId = null;

    await _secure.delete(key: _kAccessToken);
    await _secure.delete(key: _kAccessTokenExp);
    await _secure.delete(key: _kRefreshToken);
    await _secure.delete(key: _kRefreshTokenExp);
    await _secure.delete(key: _kUserId);
    await _secure.delete(key: _kSellerId);
  }

  static Future<void> clearAll() async {
    final preservedOnboardingSeen = onboardingSeen || (await _secure.read(key: _kOnboardingSeen)) == '1';

    accessToken = null;
    refreshToken = null;
    accessTokenExpiresAtUtc = null;
    refreshTokenExpiresAtUtc = null;
    userId = null;
    sellerId = null;
    autoLockEnabled = true;
    onboardingSeen = preservedOnboardingSeen;
    securitySetupDone = false;
    quickUnlockEnabled = false;
    biometricEnabled = false;
    pinSetupComplete = false;
    await _secure.deleteAll();
    await _safeWrite(_kOnboardingSeen, onboardingSeen ? '1' : '0');
  }

  static Future<void> setQuickUnlockEnabled(bool enabled) async {
    if (enabled && !hasUnlockMethod) {
      throw StateError('Set PIN or biometric before enabling quick unlock.');
    }
    quickUnlockEnabled = enabled;
    await _safeWrite(_kQuickUnlockEnabled, enabled ? '1' : '0');
    if (!enabled) {
      biometricEnabled = false;
      await _safeWrite(_kBiometricEnabled, '0');
      await setLocked(false);
    }
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    biometricEnabled = AppReleaseConfig.loginByBiometricEnabled && enabled;
    await _safeWrite(_kBiometricEnabled, biometricEnabled ? '1' : '0');
    await _normalizeSecurityState();
  }

  static Future<void> setPin(String pin) async {
    if (!AppReleaseConfig.loginByPinEnabled) {
      throw StateError('PIN login is disabled by admin policy.');
    }
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = sha256.convert(utf8.encode('$salt:$pin')).toString();
    await _safeWrite(_kPinSalt, salt);
    await _safeWrite(_kPinHash, hash);
    pinSetupComplete = true;
    await _safeWrite(_kPinSetupComplete, '1');
    await _normalizeSecurityState(enableQuickUnlockWhenPossible: true);
  }

  static Future<void> removePin() async {
    pinSetupComplete = false;
    await _secure.delete(key: _kPinSalt);
    await _secure.delete(key: _kPinHash);
    await _safeWrite(_kPinSetupComplete, '0');
    await _normalizeSecurityState();
  }

  static Future<bool> verifyPin(String pin) async {
    final salt = await _secure.read(key: _kPinSalt);
    final hash = await _secure.read(key: _kPinHash);
    if (salt == null || hash == null) return false;
    final candidate = sha256.convert(utf8.encode('$salt:$pin')).toString();
    return candidate == hash;
  }

  static Future<void> markInactiveNow() async {
    await _safeWrite(_kLastInactiveAt, DateTime.now().toUtc().toIso8601String());
  }

  static Future<bool> shouldLockForInactivity({Duration timeout = const Duration(minutes: 5)}) async {
    if (!quickUnlockEnabled || !autoLockEnabled || !hasUnlockMethod) return false;
    final raw = await _secure.read(key: _kLastInactiveAt);
    final at = _tryParseDate(raw);
    if (at == null) return false;
    return DateTime.now().toUtc().difference(at) >= timeout;
  }

  static Future<void> setLocked(bool locked) async {
    await _safeWrite(_kLocked, locked ? '1' : '0');
  }

  static Future<bool> isLocked() async => (await _secure.read(key: _kLocked)) == '1';

  static Future<void> _normalizeSecurityState({bool enableQuickUnlockWhenPossible = false}) async {
    if (!hasUnlockMethod) {
      quickUnlockEnabled = false;
      await _safeWrite(_kQuickUnlockEnabled, '0');
      await setLocked(false);
      return;
    }

    if (enableQuickUnlockWhenPossible && !quickUnlockEnabled) {
      quickUnlockEnabled = true;
      await _safeWrite(_kQuickUnlockEnabled, '1');
    }
  }

  static Future<void> _safeWrite(String key, String value) async {
    try {
      await _secure.write(key: key, value: value);
    } on PlatformException catch (e) {
      final isDuplicateItem = e.code == '-25299' ||
          (e.message ?? '').toLowerCase().contains('already exists') ||
          e.toString().contains('-25299');
      if (!isDuplicateItem) rethrow;

      await _secure.delete(key: key);
      await _secure.write(key: key, value: value);
    }
  }

  static DateTime? _tryParseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }
}
