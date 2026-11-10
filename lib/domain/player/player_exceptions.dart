/// Devam bedeli için bakiye yetersiz.
class InsufficientCoinsException implements Exception {
  const InsufficientCoinsException();

  @override
  String toString() => 'insufficient_coins';
}
