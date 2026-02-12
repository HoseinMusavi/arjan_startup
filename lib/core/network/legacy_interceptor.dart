import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../error/exceptions.dart';

class LegacyInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    var data = response.data;

    if (data is String) {
      try {
        final int firstBrace = data.indexOf('{');
        if (firstBrace != -1) {
          data = data.substring(firstBrace);
        }
        data = jsonDecode(data);
        response.data = data; 
      } catch (e) {
        debugPrint("LegacyInterceptor Error: $e");
      }
    }

    if (data is Map<String, dynamic>) {
      int code = -1;
      if (data['code'] != null) {
        code = int.tryParse(data['code'].toString()) ?? -1;
      }

      if (code == 1) {
        handler.next(response);
        return;
      }

      String msg = data['msg'] ?? 'خطایی از سمت سرور رخ داد';
      // لاگ کردن خطای سرور برای ردیابی
      debugPrint("Server Error Log: Code $code - Msg: $msg");

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