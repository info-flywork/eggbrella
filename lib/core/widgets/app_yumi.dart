import 'package:eggbrella/core/di/injection.dart';
import 'package:eggbrella/domain/skins/skin.dart';
import 'package:eggbrella/domain/skins/skin_repository.dart';
import 'package:flutter/material.dart';

/// Seçili skinle Yumi görseli: şemsiye kubbesi katmanı altta, yumurta üstte.
/// [skins] verilmezse seçili skinler kullanılır ve seçim değişince yenilenir.
class AppYumi extends StatelessWidget {
  const AppYumi({
    required this.pose,
    this.skins,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    super.key,
  });

  final YumiPose pose;
  final SkinSelection? skins;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final fixed = skins;
    if (fixed != null) return _build(fixed);
    final repo = getIt<SkinRepository>();
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) => _build(repo.selection),
    );
  }

  Widget _build(SkinSelection s) {
    Widget layer(Skin skin) => Image.asset(
      skin.layerPath(pose),
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
    );
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.passthrough,
        children: [layer(s.umbrella), layer(s.egg)],
      ),
    );
  }
}
