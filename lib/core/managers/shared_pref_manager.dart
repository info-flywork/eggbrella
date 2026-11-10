import 'package:eggbrella/core/utils/enum/control_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences singleton. `AppInit` içinde `init()` çağrılır.
final class SharedPrefManager {
  SharedPrefManager._();

  static final SharedPrefManager instance = SharedPrefManager._();

  late SharedPreferences _prefs;

  static const _soundEnabledKey = 'sound_enabled';
  static const _musicEnabledKey = 'music_enabled';
  static const _hapticEnabledKey = 'haptic_enabled';
  static const _controlModeKey = 'control_mode';
  static const _coinsKey = 'coins';
  static const _bestFloorKey = 'best_floor';
  static const _gamesPlayedKey = 'games_played';
  static const _pendingEventsKey = 'pending_events';
  static const _eggSkinKey = 'egg_skin';
  static const _umbrellaSkinKey = 'umbrella_skin';
  static const _ownedProductsKey = 'owned_products';

  /// Yeni oyuncunun başlangıç bakiyesi (sunucuyla aynı).
  static const int defaultCoins = 100;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isSoundEnabled => _prefs.getBool(_soundEnabledKey) ?? true;

  Future<void> setSoundEnabled({required bool enabled}) =>
      _prefs.setBool(_soundEnabledKey, enabled);

  bool get isMusicEnabled => _prefs.getBool(_musicEnabledKey) ?? true;

  Future<void> setMusicEnabled({required bool enabled}) =>
      _prefs.setBool(_musicEnabledKey, enabled);

  bool get isHapticEnabled => _prefs.getBool(_hapticEnabledKey) ?? true;

  Future<void> setHapticEnabled({required bool enabled}) =>
      _prefs.setBool(_hapticEnabledKey, enabled);

  ControlMode get controlMode =>
      ControlMode.fromKey(_prefs.getString(_controlModeKey));

  Future<void> setControlMode(ControlMode mode) =>
      _prefs.setString(_controlModeKey, mode.key);

  int get coins => _prefs.getInt(_coinsKey) ?? defaultCoins;

  Future<void> setCoins(int value) => _prefs.setInt(_coinsKey, value);

  int get bestFloor => _prefs.getInt(_bestFloorKey) ?? 0;

  Future<void> setBestFloor(int value) => _prefs.setInt(_bestFloorKey, value);

  int get gamesPlayed => _prefs.getInt(_gamesPlayedKey) ?? 0;

  Future<void> setGamesPlayed(int value) =>
      _prefs.setInt(_gamesPlayedKey, value);

  /// Sunucuya henüz gönderilemeyen oyuncu olayları (JSON).
  List<String> get pendingEvents =>
      _prefs.getStringList(_pendingEventsKey) ?? const [];

  Future<void> setPendingEvents(List<String> events) =>
      _prefs.setStringList(_pendingEventsKey, events);

  /// Seçili skinler (id).
  String? get eggSkin => _prefs.getString(_eggSkinKey);

  Future<void> setEggSkin(String id) => _prefs.setString(_eggSkinKey, id);

  String? get umbrellaSkin => _prefs.getString(_umbrellaSkinKey);

  Future<void> setUmbrellaSkin(String id) =>
      _prefs.setString(_umbrellaSkinKey, id);

  /// Son bilinen satın alınmış ürünler (çevrimdışı açılış için önbellek).
  List<String> get ownedProducts =>
      _prefs.getStringList(_ownedProductsKey) ?? const [];

  Future<void> setOwnedProducts(List<String> ids) =>
      _prefs.setStringList(_ownedProductsKey, ids);
}
