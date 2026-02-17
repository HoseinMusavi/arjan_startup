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
    final String lat = prefs.getDouble('user_lat')?.toString() ?? "30.5882768"; 
    final String lng = prefs.getDouble('user_lng')?.toString() ?? "50.2575974";
    return {"lat": lat, "lng": lng};
  }

  // ساخت پارامترها دقیقاً طبق نسخه PWA
  Future<Map<String, dynamic>> _buildPWAParams(String searchType, int page) async {
    final prefs = getIt<SharedPreferences>();
    final location = await _getUserLocation();
    String token = prefs.getString('client_token') ?? "";

    return {
      "search_type": searchType,
      "lat": location['lat'],
      "lng": location['lng'],
      "device_platform": "android",
      "device_id": "device_01231",
      "device_uiid": "uiid_01234561",
      "code_version": "1.5",
      "lang": "ir",
      "current_page": "tabbar",
      "user_token": token, // ارسال توکن چون در اندپوینت درست (searchMerchant) کار می‌کند
      // "page": page, // پارامتر page را فعلا نمی‌فرستیم چون در لینک PWA نبود، مگر برای صفحه بعدی
    };
  }

  @override
  Future<Map<String, dynamic>> getHomeData() async {
    try {
      final response = await _client.get("/getSettings");
      final List<String> banners = [];
      if (response.statusCode == 200) {
        final details = response.data['details'];
        if (details is Map) {
          var bannerList;
          if (details['settings'] is Map && details['settings']['home_banner'] is List) {
            bannerList = details['settings']['home_banner'];
          } else if (details['banner'] is List) {
            bannerList = details['banner'];
          }
          if (bannerList != null) {
            banners.addAll((bannerList as List).map((e) => e.toString()));
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
      // برای Cuisines فعلا از همان search استفاده می‌کنیم چون معمولا جداست
      // اما اگر کار نکرد، می‌توانیم این را هم به searchMerchant تغییر دهیم
      final params = await _buildPWAParams("byLatLong", 0);
      params['carousel'] = "1";
      
      // تست با searchMerchant برای دسته‌بندی‌ها هم ضرر ندارد
      final response = await _client.get("/searchMerchant", queryParameters: params);

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
      final params = await _buildPWAParams(searchType, page);
      
      // ✅ اصلاح حیاتی: استفاده از اندپوینت صحیح طبق PWA
      const String endpoint = "/searchMerchant"; 

      debugPrint("📡 Fetching Merchants ($searchType) from $endpoint");

      final response = await _client.get(endpoint, queryParameters: params);

      if (response.statusCode == 200) {
        if (response.data['code'] == 1) {
          final details = response.data['details'];
          List rawList = [];
          if (details is Map) {
            rawList = details['list'] ?? details['data'] ?? [];
          } else if (details is List) {
            rawList = details;
          }
          return rawList.map((item) => MerchantDto.fromJson(item)).toList();
        } 
        else if (response.data['code'] == 2) {
           debugPrint("⚠️ No restaurants found (Code 2).");
           // فال‌بک به همه رستوران‌ها
           if (searchType == "byLatLong" && page == 0) {
             return getMerchants(searchType: "allMerchant", page: 0);
           }
           return [];
        }
      } 
      // اگر باز هم ارور داد (که با اندپوینت جدید بعید است)
      else {
        debugPrint("🔥 SERVER ERROR ${response.statusCode}");
        if (searchType == "byLatLong" && page == 0) {
           return getMerchants(searchType: "allMerchant", page: 0);
        }
      }
      return [];
    } catch (e) {
      debugPrint("❌ Exception: $e");
      if (page == 0 && searchType == "byLatLong") {
         return getMerchants(searchType: "allMerchant", page: 0);
      }
      return [];
    }
  }
}