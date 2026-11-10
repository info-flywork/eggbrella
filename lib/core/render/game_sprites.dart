import 'dart:async';
import 'dart:ui' as ui;

import 'package:eggbrella/domain/skins/skin.dart';
import 'package:eggbrella/generated/assets.gen.dart';
import 'package:flutter/services.dart';

/// Bir Yumi pozunun iki katmanı: önce [umbrella], üstüne [egg] çizilir.
typedef YumiLayers = ({ui.Image umbrella, ui.Image egg});

/// Oyun sahnesi görselleri (ui.Image). Seçili skin başına bir kez yüklenir;
/// oyun ve klip çizimi aynı örneği kullanır.
class GameSprites {
  GameSprites._(this.skins, this._images);

  final SkinSelection skins;
  final Map<String, ui.Image> _images;

  static final Map<String, Future<GameSprites>> _loading = {};

  /// Pozlar oyunda kullanılanlar (sahne + kırılma).
  static const List<YumiPose> _gamePoses = [
    YumiPose.calm,
    YumiPose.happy,
    YumiPose.scared,
    YumiPose.shield,
    YumiPose.broken,
  ];

  /// [skins] için görselleri yükler (aynı seçimde aynı Future döner).
  static Future<GameSprites> load([
    SkinSelection skins = SkinSelection.classic,
  ]) => _loading[skins.key] ??= _load(skins);

  static Future<GameSprites> _load(SkinSelection skins) async {
    final paths = [
      Assets.images.imgBgGameStart.path,
      Assets.images.imgBgRooftop.path,
      Assets.images.imgBgFacade.path,
      Assets.images.imgBalcony.path,
      Assets.images.imgClothesline.path,
      Assets.images.imgPigeonUp.path,
      Assets.images.imgPigeonGlide.path,
      Assets.images.imgPigeonDown.path,
      Assets.images.imgSpeedLines.path,
      for (final pose in _gamePoses) ...[
        skins.umbrella.layerPath(pose),
        skins.egg.layerPath(pose),
      ],
    ];
    final images = <String, ui.Image>{};
    try {
      await Future.wait(
        paths.map((path) async {
          final data = await rootBundle.load(path);
          final codec = await ui.instantiateImageCodec(
            data.buffer.asUint8List(),
          );
          images[path] = (await codec.getNextFrame()).image;
        }),
      );
    } on Object {
      // Başarısız yükleme önbellekte kalmasın; sonraki çağrı yeniden dener.
      unawaited(_loading.remove(skins.key));
      rethrow;
    }
    return GameSprites._(skins, images);
  }

  ui.Image get gameStart => _images[Assets.images.imgBgGameStart.path]!;
  ui.Image get rooftop => _images[Assets.images.imgBgRooftop.path]!;
  ui.Image get facade => _images[Assets.images.imgBgFacade.path]!;
  ui.Image get balcony => _images[Assets.images.imgBalcony.path]!;
  ui.Image get clothesline => _images[Assets.images.imgClothesline.path]!;

  /// Güvercin kanat çırpma kareleri (kanatlar yukarı, orta, aşağı); aynı
  /// tuvalde gövdeye göre hizalı (scripts: .design/raw/pigeon_*.png).
  ui.Image get pigeonUp => _images[Assets.images.imgPigeonUp.path]!;
  ui.Image get pigeonGlide => _images[Assets.images.imgPigeonGlide.path]!;
  ui.Image get pigeonDown => _images[Assets.images.imgPigeonDown.path]!;
  ui.Image get speedLines => _images[Assets.images.imgSpeedLines.path]!;

  YumiLayers yumi(YumiPose pose) => (
    umbrella: _images[skins.umbrella.layerPath(pose)]!,
    egg: _images[skins.egg.layerPath(pose)]!,
  );
}
