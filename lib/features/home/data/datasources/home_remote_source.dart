import 'dart:developer';

import '../../../../core/network/dio_client.dart';
import '../models/merchant_dto.dart';
import '../models/cuisine_dto.dart';

abstract class HomeRemoteDataSource {
  Future<List<MerchantDto>> getMerchants(String searchType, double lat, double lng);
  Future<List<CuisineDto>> getCuisines();
  Future<List<String>> getBanners();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _dioClient;

  HomeRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<MerchantDto>> getMerchants(String searchType, double lat, double lng) async {
    try {
      final response = await _dioClient.get(
        '/searchMerchant',
        queryParameters: {
          'search_type': searchType,
          'lat': lat,
          'lng': lng,
        },
      );

      final data = response.data;
      
      // ✅ مدیریت صحیح زمانی که سرور لیست خالی برمی‌گرداند (Code 2)
      if (data['code'] == 2) {
        log('🟢 سرور برای لیست $searchType دیتایی نداشت (Code 2).');
        return [];
      }

      if (data['code'] == 1 && data['details'] != null && data['details']['list'] != null) {
        final List<dynamic> list = data['details']['list'];
        log('🟢 دریافت ${list.length} فروشگاه برای لیست $searchType');
        return list.map((json) => MerchantDto.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      log('🔴 خطا در دریافت لیست $searchType: $e');
      return []; // در صورت خطای شبکه، یک لیست خالی برمی‌گردانیم تا کل صفحه کرش نکند
    }
  }

  @override
  Future<List<CuisineDto>> getCuisines() async {
    try {
      // ✅ طبق لاگ‌ها، دسته‌بندی‌ها درون /getSettings هستند
      final response = await _dioClient.get('/getSettings');
      final data = response.data;

      if (data['code'] == 1 && data['details'] != null) {
        final settings = data['details']['settings'];
        if (settings != null && settings['cuisine'] != null) {
          final List<dynamic> cuisines = settings['cuisine'];
          log('🟢 دریافت ${cuisines.length} دسته‌بندی');
          return cuisines.map((e) => CuisineDto.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      log('🔴 خطا در دریافت دسته‌بندی‌ها: $e');
      return [];
    }
  }

  @override
  Future<List<String>> getBanners() async {
    try {
      // ✅ دریافت بنرهای اصلی از تنظیمات
      final response = await _dioClient.get('/getSettings');
      final data = response.data;

      if (data['code'] == 1 && data['details'] != null) {
        final settings = data['details']['settings'];
        if (settings != null && settings['home_banner'] != null) {
          final List<dynamic> banners = settings['home_banner'];
          log('🟢 دریافت ${banners.length} بنر');
          return banners.map((e) => e.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      log('🔴 خطا در دریافت بنرها: $e');
      return [];
    }
  }
}