import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cuisine_dto.dart';
import '../models/merchant_dto.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> getHomeData(); // بنرها
  Future<List<CuisineDto>> getCuisines(); // دسته‌بندی‌ها
  Future<List<MerchantDto>> getMerchants({required String searchType, int page = 0}); // لیست‌های متنوع
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _client;
  HomeRemoteDataSourceImpl(this._client);

  // مختصات دقیق بهبهان (طبق لاگ)
  static const String _lat = "30.0549908";
  static const String _lng = "50.1601352";

  // متد کمکی برای ساخت پارامترهای مشترک
  Map<String, dynamic> _buildCommonParams() {
    final prefs = getIt<SharedPreferences>();
    return {
      "lat": _lat,
      "lng": _lng,
      "device_platform": "android",
      "user_token": prefs.getString('client_token') ?? "",
      "lang": "ir",
      "current_page": "tabbar",
    };
  }

  @override
  Future<Map<String, dynamic>> getHomeData() async {
    debugPrint("📡 API: getSettings (Banners)...");
    try {
      final response = await _client.get("/getSettings");
      final List<String> banners = [];
      final settings = response.data['details']?['settings'];
      
      if (settings != null && settings['home_banner'] != null) {
        banners.addAll((settings['home_banner'] as List).map((e) => e.toString()));
      }
      return {"banners": banners};
    } catch (e) {
      debugPrint("❌ Banner Error: $e");
      return {"banners": []};
    }
  }

  @override
  Future<List<CuisineDto>> getCuisines() async {
    debugPrint("📡 API: Cuisines (Carousel)...");
    try {
      final params = _buildCommonParams();
      params.addAll({
        "carousel": "1",
        "search_type": "byLatLong", // طبق لاگ، این هم ارسال می‌شود
      });

      final response = await _client.get("/search", queryParameters: params);

      if (response.data['code'] == 1) {
        final List rawList = response.data['details']?['list'] ?? [];
        return rawList
            .where((item) => item['id'] != 0 && item['name'] != "") // حذف آیتم‌های پوچ
            .map((item) => CuisineDto.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ Cuisine Error: $e");
      return [];
    }
  }

  @override
  Future<List<MerchantDto>> getMerchants({required String searchType, int page = 0}) async {
    debugPrint("📡 API: Merchants ($searchType)...");
    try {
      final params = _buildCommonParams();
      params.addAll({
        "search_type": searchType,
        "page": page,
      });

      final response = await _client.get("/search", queryParameters: params);

      if (response.data['code'] == 1) {
        final details = response.data['details'];
        List rawList = [];
        
        // هندل کردن تفاوت ساختار خروجی (گاهی list است گاهی data)
        if (details is Map) {
          rawList = details['list'] ?? details['data'] ?? [];
        } else if (details is List) {
          rawList = details;
        }

        return rawList.map((item) => MerchantDto.fromJson(item)).toList();
      } else {
        debugPrint("⚠️ API ($searchType) Returned Code: ${response.data['code']} (Likely empty)");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Merchant Error ($searchType): $e");
      return [];
    }
  }
}