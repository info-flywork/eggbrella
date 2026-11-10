/// Şemsiye kontrolü (Ayarlar > Kontrol).
enum ControlMode {
  /// Basılı tutarken şemsiye açık, bırakınca kapanır.
  hold('hold'),

  /// Her dokunuş şemsiyeyi açar / kapatır.
  toggle('toggle');

  const ControlMode(this.key);

  final String key;

  static ControlMode fromKey(String? key) =>
      values.firstWhere((m) => m.key == key, orElse: () => hold);
}
