import 'dart:io';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Klibi sistem paylaşım sayfasıyla paylaşır (Figma "paylasim").
///
/// iOS'ta yerel kanal kullanılır: başlıkta uygulama ikonu, [title] ve
/// [subtitle] ("Video · 8 sn") görünür ve asıl öğe video olur. Android'de
/// share_plus video + metni gönderir; seçici başlığı [title] olur.
class ClipShare {
  ClipShare([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('eggbrella/clip_share');

  final MethodChannel _channel;

  Future<void> share({
    required File file,
    required String title,
    required String subtitle,
    String? text,
    Rect? origin,
  }) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod<void>('share', {
        'path': file.path,
        'title': title,
        'subtitle': subtitle,
        'text': text,
        if (origin != null)
          'origin': [origin.left, origin.top, origin.width, origin.height],
      });
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'video/mp4')],
        text: text,
        title: title,
        subject: title,
        sharePositionOrigin: origin,
      ),
    );
  }
}
