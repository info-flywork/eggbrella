import 'package:eggbrella/core/managers/auth_cache_manager.dart';
import 'package:eggbrella/core/network/network_exception.dart';
import 'package:eggbrella/core/network/network_manager.dart';
import 'package:eggbrella/core/utils/constants/string_constants.dart';
import 'package:eggbrella/core/utils/enum/request_type.dart';
import 'package:eggbrella/core/utils/id_generator.dart';
import 'package:eggbrella/data/model/auth/device_login_response.dart';
import 'package:eggbrella/data/model/token/token.dart';
import 'package:eggbrella/data/model/user/user.dart';
import 'package:flutter/foundation.dart';

/// Cihaz bazlı anonim oturum: `POST /auth/device`. [enabled] false ise
/// (çevrimdışı mod) hiçbir istek atılmaz.
class AuthRepository {
  AuthRepository(
    this._networkManager,
    this._authCacheManager, {
    required this.enabled,
    this.baseUrl = StringConstants.baseUrl,
  });

  final NetworkManager _networkManager;
  final AuthCacheManager _authCacheManager;
  final bool enabled;

  /// Oturumun ait olduğu backend; farklı bir backend'in oturumu kullanılmaz.
  final String baseUrl;

  /// Bu backend'e ait kayıtlı oturum varsa onu, yoksa cihaz kimliğiyle yeni
  /// oturum açar.
  Future<User?> ensureSession() async {
    if (!enabled) return null;
    final token = await _authCacheManager.getAccessToken();
    final user = await _authCacheManager.getUser();
    final host = await _authCacheManager.getSessionHost();
    if (token != null && token.isNotEmpty && user != null) {
      if (host == baseUrl) return user;
      await _authCacheManager.clearAll();
    }

    var deviceId = await _authCacheManager.getDeviceId();
    if (deviceId == null) {
      deviceId = IdGenerator.uuid();
      await _authCacheManager.saveDeviceId(deviceId);
    }
    final result = await _networkManager.send<DeviceLoginResponse>(
      path: '/auth/device',
      method: RequestType.post,
      parserModel: DeviceLoginResponse.fromJson,
      data: {'device_id': deviceId, 'platform': defaultTargetPlatform.name},
    );
    final newUser = result?.user;
    if (result == null || newUser == null) {
      throw NetworkException.emptyResponse();
    }
    await _authCacheManager.saveToken(
      Token(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      ),
    );
    await _authCacheManager.saveUser(newUser);
    await _authCacheManager.saveSessionHost(baseUrl);
    return newUser;
  }

  Future<bool> get hasSession async =>
      enabled && (await _authCacheManager.getAccessToken()) != null;
}
