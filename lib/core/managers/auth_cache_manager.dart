import 'dart:convert';

import 'package:eggbrella/data/model/token/token.dart';
import 'package:eggbrella/data/model/user/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT access/refresh token + user JSON -> FlutterSecureStorage
class AuthCacheManager {
  AuthCacheManager(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_json';
  static const _deviceIdKey = 'device_id';
  static const _sessionHostKey = 'session_host';

  Future<void> saveToken(Token token) async {
    await _storage.write(key: _accessTokenKey, value: token.accessToken);
    await _storage.write(key: _refreshTokenKey, value: token.refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveUser(User user) =>
      _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

  Future<User?> getUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Anonim hesabın cihaz kimliği. Keychain'de tutulduğu için iOS'ta
  /// uygulama silinip kurulsa da aynı hesaba dönülür.
  Future<String?> getDeviceId() => _storage.read(key: _deviceIdKey);

  Future<void> saveDeviceId(String id) =>
      _storage.write(key: _deviceIdKey, value: id);

  /// Oturumun açıldığı backend adresi (yerel / canlı geçişinde oturum
  /// yenilensin diye).
  Future<String?> getSessionHost() => _storage.read(key: _sessionHostKey);

  Future<void> saveSessionHost(String host) =>
      _storage.write(key: _sessionHostKey, value: host);

  /// "Verilerimi Sil": oturum, kullanıcı ve cihaz kimliği dahil her şeyi
  /// siler; bir sonraki açılışta yepyeni anonim hesap oluşur.
  Future<void> wipe() => _storage.deleteAll();

  /// Oturumu temizler; cihaz kimliği korunur.
  Future<void> clearAll() async {
    final deviceId = await getDeviceId();
    await _storage.deleteAll();
    if (deviceId != null) await saveDeviceId(deviceId);
  }
}
