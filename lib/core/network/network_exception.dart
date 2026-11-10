class NetworkException implements Exception {
  const NetworkException(this.message, {this.statusCode});

  factory NetworkException.emptyResponse() =>
      const NetworkException('Empty response');

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
