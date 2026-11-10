import 'dart:async';

import 'package:eggbrella/core/managers/shared_pref_manager.dart';
import 'package:flutter/services.dart';

/// "Titreşim" ayarına uyan dokunsal geri bildirim.
class HapticManager {
  HapticManager(this._prefs);

  final SharedPrefManager _prefs;

  void light() => _run(HapticFeedback.lightImpact);

  void medium() => _run(HapticFeedback.mediumImpact);

  /// Kırılma anı.
  void heavy() => _run(HapticFeedback.heavyImpact);

  void selection() => _run(HapticFeedback.selectionClick);

  void _run(Future<void> Function() feedback) {
    if (!_prefs.isHapticEnabled) return;
    unawaited(feedback());
  }
}
