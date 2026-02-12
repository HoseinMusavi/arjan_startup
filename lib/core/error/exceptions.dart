class ServerException implements Exception {
  final String message;
  final int code;

  ServerException({required this.message, required this.code});
}

class CacheException implements Exception {}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException({this.message = "لطفا مجددا وارد حساب کاربری شوید"});
}