import 'package:flutter/services.dart';

/// Yerel H.264 kodlayıcı köprüsü (iOS: AVAssetWriter, Android: MediaCodec).
/// Kareler ham RGBA (premultiplied, opak) olarak sırayla verilir.
class ClipEncoder {
  ClipEncoder([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('eggbrella/clip_encoder');

  final MethodChannel _channel;

  Future<void> start({
    required String path,
    required int width,
    required int height,
    required int fps,
  }) => _channel.invokeMethod<void>('start', {
    'path': path,
    'width': width,
    'height': height,
    'fps': fps,
  });

  Future<void> addFrame(Uint8List rgba) =>
      _channel.invokeMethod<void>('addFrame', rgba);

  /// Dosyayı kapatır ve yolunu döner.
  Future<String> finish() async =>
      (await _channel.invokeMethod<String>('finish'))!;

  Future<void> cancel() => _channel.invokeMethod<void>('cancel');
}
