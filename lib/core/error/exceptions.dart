class ServerException implements Exception {
  final String message;
  final int code;

  ServerException({required this.message, required this.code});

  @override
  String toString() => message; // این خط باعث می‌شود متن خطا در لاگ و UI دیده شود
}

class CacheException implements Exception {}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException({this.message = "لطفا مجددا وارد حساب کاربری شوید"});
  
  @override
  String toString() => message;
}