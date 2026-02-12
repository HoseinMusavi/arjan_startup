import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../error/exceptions.dart';

class LegacyInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    var data = response.data;

    // 1. اگر دیتا String بود (چه به خاطر هدر اشتباه، چه به خاطر خطاهای PHP)
    if (data is String) {
      try {
        // --- بخش جدید برای حل مشکل PHP Warnings ---
        // سرور شما قبل از جیسون، وارنینگ PHP چاپ می‌کند. ما باید اولین { را پیدا کنیم
        final int firstBrace = data.indexOf('{');
        if (firstBrace != -1) {
          // همه چیز قبل از { را حذف می‌کنیم
          data = data.substring(firstBrace);
        }
        // -------------------------------------------

        data = jsonDecode(data);
        response.data = data; // دیتای تمیز شده را جایگزین می‌کنیم
      } catch (e) {
        debugPrint("LegacyInterceptor: خطا در تمیزکاری و پارس جیسون - $e");
      }
    }

    // 2. ادامه پردازش مثل قبل
    if (data is Map<String, dynamic>) {
      int code = -1;
      if (data['code'] != null) {
        code = int.tryParse(data['code'].toString()) ?? -1;
      }

      if (code == 1) {
        handler.next(response);
        return;
      }

      String msg = data['msg'] ?? 'خطای ناشناخته رخ داده است';

      if (msg.toLowerCase().contains("token") || 
          msg.toLowerCase().contains("session") ||
          code == 11) { 
        throw DioException(
          requestOptions: response.requestOptions,
          error: UnauthorizedException(message: msg),
          type: DioExceptionType.badResponse,
        );
      }

      throw DioException(
        requestOptions: response.requestOptions,
        error: ServerException(message: msg, code: code),
        type: DioExceptionType.badResponse,
        response: response,
      );
    }

    handler.next(response);
  }
}