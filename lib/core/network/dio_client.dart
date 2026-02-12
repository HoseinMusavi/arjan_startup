import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // برای kDebugMode
import '../constants/app_constants.dart';
import 'legacy_interceptor.dart';

class DioClient {
  final Dio _dio;

  DioClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
            receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json',
            },
          ),
        ) {
    // فقط در حالت دیباگ و فقط هدرها را لاگ میکنیم، بادی را خاموش میکنیم
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: false, // بادی درخواست لاگ نشود
        responseBody: false, // بادی پاسخ (جیسون طولانی) لاگ نشود
        requestHeader: false, 
        responseHeader: false,
        error: true, // فقط ارورها لاگ شوند
      ));
    }
    _dio.interceptors.add(LegacyInterceptor());
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final Map<String, dynamic> params = queryParameters ?? {};
    params['api_key'] = AppConstants.apiKey;
    params['lang'] = 'fa'; 
    return await _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters}) async {
    final Map<String, dynamic> params = queryParameters ?? {};
    params['api_key'] = AppConstants.apiKey;
    params['lang'] = 'fa';

    FormData? formData;
    if (data != null) {
      formData = FormData.fromMap(data);
    }

    return await _dio.post(path, data: formData, queryParameters: params);
  }
}