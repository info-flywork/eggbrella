import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:eggbrella/core/clip/clip_encoder.dart';
import 'package:eggbrella/core/render/game_sprites.dart';
import 'package:eggbrella/core/render/scene_renderer.dart';
import 'package:eggbrella/data/model/clip/clip_upload_response.dart';
import 'package:eggbrella/domain/game/replay/game_replay.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Hazır klip: cihazdaki MP4 ve (yüklenebildiyse) CDN bağlantısı.
class Clip {
  const Clip({required this.file, required this.seconds, this.url});

  final File file;
  final int seconds;
  final String? url;
}

/// Oyunun son saniyelerini MP4'e çevirir ve paylaşım bağlantısı için
/// sunucuya (`POST /clips`, ham MP4 gövdesi -> Bunny CDN) yükler.
class ClipRepository {
  ClipRepository(this._dio, this._encoder, {required this.uploadEnabled});

  final Dio _dio;
  final ClipEncoder _encoder;
  final bool uploadEnabled;

  /// Video boyutu (9:16, kodlayıcılar çift sayı ister).
  static const int width = 540;
  static const int height = 960;

  /// Klip üretimi + yükleme için toplam süre sınırı.
  static const Duration uploadTimeout = Duration(seconds: 4);

  Future<Clip> create({
    required GameReplay replay,
    required String Function(int floor) floorLabel,
  }) async {
    if (replay.isEmpty) throw StateError('empty replay');
    final file = await _render(replay, floorLabel);
    final url = await _upload(file);
    return Clip(file: file, seconds: replay.durationSeconds.round(), url: url);
  }

  Future<File> _render(
    GameReplay replay,
    String Function(int floor) floorLabel,
  ) async {
    final sprites = await GameSprites.load(replay.skins);
    final renderer = SceneRenderer(sprites);
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/eggbrella_${DateTime.now().millisecondsSinceEpoch}.mp4';
    await _encoder.start(
      path: path,
      width: width,
      height: height,
      fps: replay.fps,
    );
    try {
      const size = ui.Size(width + 0.0, height + 0.0);
      final frames = replay.frames;
      for (var i = 0; i < frames.length; i++) {
        final s = frames[i];
        final recorder = ui.PictureRecorder();
        renderer.paint(
          ui.Canvas(recorder),
          size,
          s,
          time: i / replay.fps,
          floorLabel: floorLabel(s.floor),
        );
        final picture = recorder.endRecording();
        final image = await picture.toImage(width, height);
        picture.dispose();
        final bytes = await image.toByteData();
        image.dispose();
        if (bytes == null) throw StateError('frame readback failed');
        await _encoder.addFrame(bytes.buffer.asUint8List());
      }
      return File(await _encoder.finish());
    } on Object {
      unawaited(_encoder.cancel().catchError((_) {}));
      rethrow;
    }
  }

  /// Bağlantı paylaşımı için yükleme; başarısızsa klip yine paylaşılır.
  Future<String?> _upload(File file) async {
    if (!uploadEnabled) return null;
    try {
      final response = await _dio
          .post<Map<String, dynamic>>(
            '/clips',
            data: file.openRead(),
            options: Options(
              contentType: 'video/mp4',
              headers: {Headers.contentLengthHeader: await file.length()},
            ),
          )
          .timeout(uploadTimeout);
      final data = response.data?['data'];
      if (data is! Map<String, dynamic>) return null;
      return ClipUploadResponse.fromJson(data).url;
    } on Object catch (e) {
      debugPrint('ClipRepository.upload: $e');
      return null;
    }
  }
}
