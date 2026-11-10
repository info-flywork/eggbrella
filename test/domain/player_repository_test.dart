import 'dart:convert';

import 'package:eggbrella/core/managers/shared_pref_manager.dart';
import 'package:eggbrella/domain/player/player_exceptions.dart';
import 'package:eggbrella/domain/player/player_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late PlayerRepository repository;
  final prefs = SharedPrefManager.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await prefs.init();
    repository = PlayerRepository(prefs);
  });

  test('yeni oyuncu 100 coin ve 0 rekorla başlar', () {
    final p = repository.progress;
    expect(p.coins, SharedPrefManager.defaultCoins);
    expect(p.bestFloor, 0);
    expect(p.continuePrice, 50);
  });

  test(
    'oyun sonu: coin eklenir, rekor yalnızca artar, olay kuyruğa girer',
    () async {
      await repository.recordGame(
        floor: 40,
        coinsCollected: 12,
        continuesUsed: 0,
        durationMs: 30000,
      );
      await repository.recordGame(
        floor: 10,
        coinsCollected: 3,
        continuesUsed: 0,
        durationMs: 9000,
      );
      final p = repository.progress;
      expect(p.coins, 115);
      expect(p.bestFloor, 40);
      expect(p.gamesPlayed, 2);
      final events = prefs.pendingEvents
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
      expect(events.map((e) => e['type']), ['game_over', 'game_over']);
      expect(events.first['id'], isNot(events.last['id']));
    },
  );

  test('devam bedeli bakiyeden düşer; yetmezse hata', () async {
    await repository.spendForContinue(50);
    expect(repository.progress.coins, 50);
    await repository.spendForContinue(50);
    expect(
      () => repository.spendForContinue(1),
      throwsA(isA<InsufficientCoinsException>()),
    );
  });
}
