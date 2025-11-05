abstract class AppException implements Exception {
  final String message;
  final int statusCode;

  AppException(this.message, this.statusCode);
}

class ServerException extends AppException {
  ServerException(super.message, super.statusCode);
}

class CacheException extends AppException {
  CacheException(String message) : super(message, 500);
}