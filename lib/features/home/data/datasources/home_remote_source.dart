import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cuisine_dto.dart';
import '../models/merchant_dto.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> getHomeData();
  Future<List<CuisineDto>> getCuisines();
  Future<List<MerchantDto>> getMerchants({required String searchType, int page = 0});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _client;
  HomeRemoteDataSourceImpl(this._client);

  Future<Map<String, String>> _getUserLocation() async {
    final prefs = getIt<SharedPreferences>();
    // استفاده از مختصات ذخیره شده یا دیفالت (طبق لاگ شما)
    final String lat = prefs.getDouble('user_lat')?.toString() ?? "30.5882768"; 
    final String lng = prefs.getDouble('user_lng')?.toString() ?? "50.2575974";
    return {"lat": lat, "lng": lng};
  }

  // ✅ ساخت پارامترها دقیقا طبق لاگ موفق سرور
  Future<Map<String, dynamic>> _buildExactParams(String searchType, int page) async {
    final prefs = getIt<SharedPreferences>();
    final location = await _getUserLocation();
    String token = prefs.getString('client_token') ?? "";

    return {
      "search_type": searchType,
      "lat": location['lat'],
      "lng": location['lng'],
      "page": page,
      // پارامترهای حیاتی (طبق لاگ شما)
      "device_platform": "android",
      "device_id": "device_01231",      // ثابت طبق لاگ
      "device_uiid": "uiid_01234561",   // ✅ نکته طلایی: uiid به جای uuid
      "code_version": "1.5",
      "lang": "ir",
      "current_page": "tabbar",
      "user_token": token, // ارسال توکن چون در لاگ موفق وجود داشت
    };
  }

  @override
  Future<Map<String, dynamic>> getHomeData() async {
    try {
      final response = await _client.get("/getSettings");
      final List<String> banners = [];
      if (response.statusCode == 200) {
        final details = response.data['details'];
        // تلاش برای یافتن بنر در ساختارهای مختلف
        if (details is Map) {
          if (details['settings'] is Map && details['settings']['home_banner'] is List) {
            banners.addAll((details['settings']['home_banner'] as List).map((e) => e.toString()));
          } else if (details['banner'] is List) {
            banners.addAll((details['banner'] as List).map((e) => e.toString()));
          }
        }
      }
      return {"banners": banners};
    } catch (e) {
      return {"banners": []};
    }
  }

  @override
  Future<List<CuisineDto>> getCuisines() async {
    try {
      final params = await _buildExactParams("byLatLong", 0);
      params['carousel'] = "1";
      
      final response = await _client.get("/search", queryParameters: params);

      if (response.statusCode == 200 && response.data['code'] == 1) {
        final List rawList = response.data['details']?['list'] ?? [];
        return rawList
            .where((item) => item is Map && item['id'] != 0)
            .map((item) => CuisineDto.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<MerchantDto>> getMerchants({required String searchType, int page = 0}) async {
    try {
      final params = await _buildExactParams(searchType, page);
      debugPrint("📡 Fetching Merchants ($searchType) - UIID Fixed");

      final response = await _client.get("/search", queryParameters: params);

      // بررسی کد پاسخ
      if (response.statusCode == 200) {
        final int code = response.data['code'] is int ? response.data['code'] : int.tryParse(response.data['code'].toString()) ?? 0;
        
        // حالت ۱: موفقیت و وجود لیست
        if (code == 1) {
          final details = response.data['details'];
          List rawList = [];
          
          if (details is Map) {
            rawList = details['list'] ?? details['data'] ?? [];
          } else if (details is List) {
            rawList = details;
          }

          return rawList.map((item) => MerchantDto.fromJson(item)).toList();
        } 
        // حالت ۲: هیچ نتیجه‌ای یافت نشد (مثل پاسخی که برای special_Offers فرستادید)
        else if (code == 2) {
          debugPrint("⚠️ No results for $searchType (Code 2)");
          return []; // لیست خالی برمی‌گردانیم تا ارور نمایش داده نشود
        }
      }
      return [];
    } catch (e) {
      debugPrint("❌ Exception: $e");
      return [];
    }
  }
}