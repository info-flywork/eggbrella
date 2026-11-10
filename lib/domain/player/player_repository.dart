import 'dart:async';
import 'dart:convert';

import 'package:eggbrella/core/managers/shared_pref_manager.dart';
import 'package:eggbrella/core/network/network_exception.dart';
import 'package:eggbrella/core/network/network_manager.dart';
import 'package:eggbrella/core/utils/enum/request_type.dart';
import 'package:eggbrella/core/utils/id_generator.dart';
import 'package:eggbrella/data/model/player/player_progress.dart';
import 'package:eggbrella/data/model/player/purchase_sync_response.dart';
import 'package:eggbrella/domain/player/player_exceptions.dart';
import 'package:flutter/foundation.dart';

/// Oyuncu ilerlemesi (coin, rekor, oyun sayısı). Önce cihaza yazılır, sonra
/// sunucuya `client_event_id` ile idempotent olaylar olarak gönderilir;
/// çevrimdışıyken olaylar kuyrukta bekler. [_network] null ise (çevrimdışı
/// mod) yalnızca yerel çalışır.
class PlayerRepository {
  PlayerRepository(this._prefs, [this._network]);

  final SharedPrefManager _prefs;
  final NetworkManager? _network;
  Future<void>? _flushing;
  int _continuePrice = PlayerProgress.defaultContinuePrice;

  PlayerProgress get progress => PlayerProgress(
    coins: _prefs.coins,
    bestFloor: _prefs.bestFloor,
    gamesPlayed: _prefs.gamesPlayed,
    continuePrice: _continuePrice,
  );

  /// Bekleyen olayları gönderir, sonra sunucu durumunu alır. Hata olursa
  /// sessizce yerel durumla devam edilir.
  Future<PlayerProgress> refresh() async {
    final network = _network;
    if (network == null) return progress;
    try {
      await flush();
      if (_prefs.pendingEvents.isNotEmpty) return progress;
      final server = await network.send<PlayerProgress>(
        path: '/player/progress',
        method: RequestType.get,
        parserModel: PlayerProgress.fromJson,
      );
      if (server != null) await _adopt(server);
    } on NetworkException catch (e) {
      debugPrint('PlayerRepository.refresh: $e');
    }
    return progress;
  }

  /// Oyun bitti: rekor, oyun sayısı ve toplanan coin'ler.
  Future<PlayerProgress> recordGame({
    required int floor,
    required int coinsCollected,
    required int continuesUsed,
    required int durationMs,
  }) async {
    await _prefs.setCoins(_prefs.coins + coinsCollected);
    if (floor > _prefs.bestFloor) await _prefs.setBestFloor(floor);
    await _prefs.setGamesPlayed(_prefs.gamesPlayed + 1);
    await _enqueue({
      'type': 'game_over',
      'path': '/player/game-over',
      'body': {
        'floor': floor,
        'coins_collected': coinsCollected,
        'continues_used': continuesUsed,
        'duration_ms': durationMs,
      },
    });
    return progress;
  }

  /// Kırıldıktan sonra devam bedelinin kayıtlı bakiyeden ödenen kısmı
  /// ([amount] <= devam bedeli; kalanı bu oyunda toplanan coin'lerden
  /// düşülür). Bakiye yetmezse [InsufficientCoinsException].
  Future<PlayerProgress> spendForContinue(int amount) async {
    if (amount <= 0) return progress;
    if (_prefs.coins < amount) throw const InsufficientCoinsException();
    await _prefs.setCoins(_prefs.coins - amount);
    await _enqueue({
      'type': 'continue',
      'path': '/player/continue',
      'body': {'amount': amount},
    });
    return progress;
  }

  /// Sunucuya bağlı mı (coin paketlerini yalnız sunucu yükleyebilir).
  bool get isRemote => _network != null;

  /// Coin paketi satın alındıktan (ya da geri yüklendikten) sonra sunucu
  /// RevenueCat'teki işlemleri doğrulayıp yükler (`POST /purchases/sync`,
  /// idempotent). Bu çağrıda yüklenen coin'i döner.
  Future<int> syncPurchases() async {
    final network = _network;
    if (network == null) return 0;
    await flush();
    final result = await network.send<PurchaseSyncResponse>(
      path: '/purchases/sync',
      method: RequestType.post,
      parserModel: PurchaseSyncResponse.fromJson,
    );
    if (result == null) throw NetworkException.emptyResponse();
    if (_prefs.pendingEvents.isEmpty) {
      await _adopt(result.progress);
    } else {
      // Gönderilemeyen yerel olaylar varken sunucu bakiyesi eksik kalır;
      // yalnızca yeni yüklenen coin eklenir.
      await _prefs.setCoins(_prefs.coins + result.creditedCoins);
    }
    return result.creditedCoins;
  }

  /// Yalnızca çevrimdışı modda (sunucu yok) sahte satın alma sonrası coin
  /// yükler; sunucuya bağlıyken coin'i yalnızca sunucu yükler.
  Future<void> creditOfflinePurchase(int coins) async {
    if (isRemote) return;
    await _prefs.setCoins(_prefs.coins + coins);
  }

  /// Kuyruktaki olayları sırayla gönderir. Ağ hatasında durur (sonra tekrar
  /// denenir); sunucu bir olayı reddederse (4xx) olay atılır.
  Future<void> flush() => _flushing ??= _flush().whenComplete(() {
    _flushing = null;
  });

  Future<void> _flush() async {
    final network = _network;
    if (network == null) return;
    while (_prefs.pendingEvents.isNotEmpty) {
      final raw = _prefs.pendingEvents.first;
      final event = jsonDecode(raw) as Map<String, dynamic>;
      try {
        final server = await network.send<PlayerProgress>(
          path: event['path'] as String,
          method: RequestType.post,
          parserModel: PlayerProgress.fromJson,
          data: {
            ...(event['body'] as Map<String, dynamic>),
            'client_event_id': event['id'],
          },
        );
        await _dropFirst(raw);
        if (server != null && _prefs.pendingEvents.isEmpty) {
          await _adopt(server);
        }
      } on NetworkException catch (e) {
        final status = e.statusCode;
        if (status != null && status >= 400 && status < 500 && status != 401) {
          debugPrint('PlayerRepository: olay reddedildi (${e.message})');
          await _dropFirst(raw);
          continue;
        }
        return;
      }
    }
  }

  Future<void> _enqueue(Map<String, dynamic> event) async {
    final withId = {...event, 'id': IdGenerator.uuid()};
    await _prefs.setPendingEvents([
      ..._prefs.pendingEvents,
      jsonEncode(withId),
    ]);
    unawaited(flush());
  }

  Future<void> _dropFirst(String raw) async {
    final events = [..._prefs.pendingEvents]..remove(raw);
    await _prefs.setPendingEvents(events);
  }

  /// Sunucu coin'de yetkilidir; rekor ve oyun sayısında büyük olan kalır.
  Future<void> _adopt(PlayerProgress server) async {
    _continuePrice = server.continuePrice;
    await _prefs.setCoins(server.coins);
    if (server.bestFloor > _prefs.bestFloor) {
      await _prefs.setBestFloor(server.bestFloor);
    }
    if (server.gamesPlayed > _prefs.gamesPlayed) {
      await _prefs.setGamesPlayed(server.gamesPlayed);
    }
  }
}
