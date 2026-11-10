import 'package:equatable/equatable.dart';

sealed class ResultEvent extends Equatable {
  const ResultEvent();

  @override
  List<Object?> get props => [];
}

/// "Klibi paylaş" ya da hata kartında "Tekrar dene".
final class ResultShareTapped extends ResultEvent {
  const ResultShareTapped();
}

/// Hazırlanıyor kartında "Vazgeç" ya da hata kartında "Kapat".
final class ResultClipDismissed extends ResultEvent {
  const ResultClipDismissed();
}

/// Sistem paylaşım sayfası kapandı.
final class ResultShareClosed extends ResultEvent {
  const ResultShareClosed();
}
