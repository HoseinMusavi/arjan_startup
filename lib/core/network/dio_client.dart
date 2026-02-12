import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
        error: true,
      ));
    }
    _dio.interceptors.add(LegacyInterceptor());
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final Map<String, dynamic> params = queryParameters ?? {};
    params['api_key'] = AppConstants.apiKey;
    // تغییر مهم: زبان را روی ir گذاشتیم چون سرور شما روی این زبان تنظیم شده است
    params['lang'] = 'ir'; 
    
    return await _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters}) async {
    final Map<String, dynamic> params = queryParameters ?? {};
    params['api_key'] = AppConstants.apiKey;
    // تغییر مهم: زبان را روی ir گذاشتیم
    params['lang'] = 'ir';

    FormData? formData;
    if (data != null) {
      formData = FormData.fromMap(data);
    }

    return await _dio.post(path, data: formData, queryParameters: params);
  }
}