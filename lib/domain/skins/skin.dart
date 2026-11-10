import 'package:equatable/equatable.dart';

/// Skinin uygulandığı parça.
enum SkinSlot { egg, umbrella }

/// Yumi görsel pozları; her poz iki katmandır (şemsiye kubbesi + yumurta),
/// `scripts/make_skins.py` üretir. Üst üste çizilince orijinal görsel olur.
enum YumiPose { calm, happy, scared, shield, sleep, bandaged, broken }

/// Satılabilir görünüm. [productId] null ise ücretsizdir (klasik).
final class Skin extends Equatable {
  const Skin({
    required this.id,
    required this.slot,
    this.productId,
  });

  final String id;
  final SkinSlot slot;

  /// App Store / Play non-consumable ürün kimliği.
  final String? productId;

  bool get isFree => productId == null;

  /// Pozun bu skine ait katman görseli.
  String layerPath(YumiPose pose) =>
      'assets/skins/${slot.name}/$id/${pose.name}.png';

  /// Çeviri anahtarı: `skins.egg.golden` gibi.
  String get nameKey => 'skins.${slot.name}_$id';

  @override
  List<Object?> get props => [id, slot];
}

/// Mağazadaki skinler (assetlerle aynı sırada).
abstract final class SkinCatalog {
  static const _prefix = 'com.flywork.eggbrella';

  static const classicEgg = Skin(id: 'classic', slot: SkinSlot.egg);
  static const classicUmbrella = Skin(id: 'classic', slot: SkinSlot.umbrella);

  static const List<Skin> eggs = [
    classicEgg,
    Skin(id: 'golden', slot: SkinSlot.egg, productId: '$_prefix.egg_golden'),
    Skin(
      id: 'chocolate',
      slot: SkinSlot.egg,
      productId: '$_prefix.egg_chocolate',
    ),
    Skin(id: 'mint', slot: SkinSlot.egg, productId: '$_prefix.egg_mint'),
    Skin(id: 'dino', slot: SkinSlot.egg, productId: '$_prefix.egg_dino'),
    Skin(id: 'galaxy', slot: SkinSlot.egg, productId: '$_prefix.egg_galaxy'),
    Skin(
      id: 'bubblegum',
      slot: SkinSlot.egg,
      productId: '$_prefix.egg_bubblegum',
    ),
  ];

  static const List<Skin> umbrellas = [
    classicUmbrella,
    Skin(
      id: 'ocean',
      slot: SkinSlot.umbrella,
      productId: '$_prefix.umbrella_ocean',
    ),
    Skin(
      id: 'lime',
      slot: SkinSlot.umbrella,
      productId: '$_prefix.umbrella_lime',
    ),
    Skin(
      id: 'grape',
      slot: SkinSlot.umbrella,
      productId: '$_prefix.umbrella_grape',
    ),
    Skin(
      id: 'sunny',
      slot: SkinSlot.umbrella,
      productId: '$_prefix.umbrella_sunny',
    ),
    Skin(
      id: 'midnight',
      slot: SkinSlot.umbrella,
      productId: '$_prefix.umbrella_midnight',
    ),
    Skin(
      id: 'rainbow',
      slot: SkinSlot.umbrella,
      productId: '$_prefix.umbrella_rainbow',
    ),
  ];

  static List<Skin> of(SkinSlot slot) => switch (slot) {
    SkinSlot.egg => eggs,
    SkinSlot.umbrella => umbrellas,
  };

  static Skin find(SkinSlot slot, String? id) => of(slot).firstWhere(
    (s) => s.id == id,
    orElse: () => of(slot).first,
  );

  static List<String> get productIds => [
    for (final s in [...eggs, ...umbrellas]) ?s.productId,
  ];
}

/// Seçili yumurta + şemsiye.
final class SkinSelection extends Equatable {
  const SkinSelection({required this.egg, required this.umbrella});

  static const classic = SkinSelection(
    egg: SkinCatalog.classicEgg,
    umbrella: SkinCatalog.classicUmbrella,
  );

  final Skin egg;
  final Skin umbrella;

  Skin of(SkinSlot slot) => switch (slot) {
    SkinSlot.egg => egg,
    SkinSlot.umbrella => umbrella,
  };

  SkinSelection withSkin(Skin skin) => switch (skin.slot) {
    SkinSlot.egg => SkinSelection(egg: skin, umbrella: umbrella),
    SkinSlot.umbrella => SkinSelection(egg: egg, umbrella: skin),
  };

  String get key => '${egg.id}|${umbrella.id}';

  @override
  List<Object?> get props => [egg, umbrella];
}
