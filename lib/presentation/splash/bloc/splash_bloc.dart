import 'dart:async';

import 'package:eggbrella/core/render/game_sprites.dart';
import 'package:eggbrella/core/sound/sound_manager.dart';
import 'package:eggbrella/data/model/user/user.dart';
import 'package:eggbrella/domain/auth/auth_repository.dart';
import 'package:eggbrella/domain/player/player_repository.dart';
import 'package:eggbrella/domain/purchase/purchase_repository.dart';
import 'package:eggbrella/domain/skins/skin.dart';
import 'package:eggbrella/domain/skins/skin_repository.dart';
import 'package:eggbrella/presentation/splash/bloc/splash_event.dart';
import 'package:eggbrella/presentation/splash/bloc/splash_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Açılış: marka yazısı, ardından yükleme (sesler, oyun görselleri, oturum,
/// ilerleme). Ağ hatası açılışı durdurmaz; oyun çevrimdışı da oynanır.
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc(
    this._auth,
    this._player,
    this._sound, {
    this.purchases,
    this.skins,
  }) : super(const SplashBrand()) {
    on<SplashStarted>(_onStarted);
  }

  final AuthRepository _auth;
  final PlayerRepository _player;
  final SoundManager _sound;

  /// Verilmezse (testler) satın alma / skin adımları atlanır.
  final PurchaseRepository? purchases;
  final SkinRepository? skins;

  /// Figma: marka yazısı 1 sn'de yazılır; kısa bir bekleme.
  static const brandDuration = Duration(milliseconds: 1600);

  /// Figma acilis: "2 sn sonra otomatik olarak ana sayfaya geçer".
  static const loadingMinDuration = Duration(seconds: 2);
  static const networkTimeout = Duration(seconds: 5);
  static const assetTimeout = Duration(seconds: 4);

  Future<void> _onStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    final assets = Future.wait([
      _sound.preload(),
      GameSprites.load(skins?.selection ?? SkinSelection.classic),
    ]);
    await Future<void>.delayed(brandDuration);
    emit(const SplashLoading(progress: 0.1));

    final minimum = Future<void>.delayed(loadingMinDuration);
    // Ses ya da görsel yüklemesi takılırsa açılış beklemez (oyun sessiz /
    // görseller ilk kullanımda yüklenir).
    try {
      await assets.timeout(assetTimeout);
    } on Object catch (e) {
      debugPrint('Splash: asset yükleme hatası: $e');
    }
    emit(const SplashLoading(progress: 0.45));

    User? user;
    try {
      user = await _auth.ensureSession().timeout(networkTimeout);
      emit(const SplashLoading(progress: 0.6));
      await _player.refresh().timeout(networkTimeout);
    } on Object catch (e) {
      debugPrint('Splash: çevrimdışı devam: $e');
    }
    emit(const SplashLoading(progress: 0.75));
    // RevenueCat ağ olmasa da başlatılır (mağaza açılabilsin); app user id
    // backend kullanıcı id'sidir, böylece geri yükleme hesaba bağlı olur.
    try {
      await purchases?.configure(appUserId: user?.id);
      await skins?.refresh().timeout(networkTimeout);
    } on Object catch (e) {
      debugPrint('Splash: satın alma başlatılamadı: $e');
    }
    emit(const SplashLoading(progress: 0.9));
    await minimum;
    emit(const SplashLoading(progress: 1));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    emit(const SplashFinished());
  }
}
