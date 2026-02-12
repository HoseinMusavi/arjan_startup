import 'package:dio/dio.dart';
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
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false,
      responseHeader: false,
      error: true,
    ));
    _dio.interceptors.add(LegacyInterceptor());
  }

  // ... بقیه کدها مثل قبل (بدون تغییر) ...
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final Map<String, dynamic> params = queryParameters ?? {};
    params['api_key'] = AppConstants.apiKey;
    params['lang'] = 'ir'; 
    return await _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters}) async {
    final Map<String, dynamic> params = queryParameters ?? {};
    params['api_key'] = AppConstants.apiKey;
    params['lang'] = 'ir';

    FormData? formData;
    if (data != null) {
      formData = FormData.fromMap(data);
    }

    return await _dio.post(path, data: formData, queryParameters: params);
  }
}