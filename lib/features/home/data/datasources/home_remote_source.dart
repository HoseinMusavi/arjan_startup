import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cuisine_dto.dart';
import '../models/merchant_dto.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> getHomeData();
  Future<List<MerchantDto>> getMerchants({int page = 0});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _client;

  HomeRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> getHomeData() async {
    // ... (کد دریافت تنظیمات و بنرها که درست کار میکند دست نزن) ...
    // کدهای قبلی خودت را اینجا بگذار یا اگر نداری بگو بفرستم
    // فقط بخش getMerchants را تغییر دادم
    
    // (برای اینکه فایل طولانی نشود، فرض میکنم کد getHomeData قبلی را داری)
    // اگر نداری بگو
    
    try {
      final response = await _client.get("/getSettings");
      final details = response.data['details'];
      final settings = details['settings'];
      
      final List<String> banners = [];
      if (settings != null && settings['home_banner'] != null) {
        for (var item in settings['home_banner']) {
          banners.add(item.toString());
        }
      }

      final List<CuisineDto> cuisines = [];
      if (settings != null && settings['cuisine'] != null) {
        final List rawList = settings['cuisine'];
        for (var item in rawList) {
          try {
            cuisines.add(CuisineDto.fromJson(item));
          } catch (_) {}
        }
      }

      return {"banners": banners, "cuisines": cuisines};

    } on DioException catch (e) {
      if (kIsWeb && _isCorsError(e)) return _getMockHomeData();
      throw ServerException(message: e.message ?? "Error", code: 500);
    }
  }

  @override
  Future<List<MerchantDto>> getMerchants({int page = 0}) async {
    debugPrint("📡 Finding correct Merchant API...");
    
    // لیست اندپوینت‌های احتمالی به ترتیب اولویت
    final endpoints = [
      {
        "url": "/search",
        "method": "POST",
        "data": {"search_type": "list", "page": page}
      },
      {
        "url": "/getMerchantList",
        "method": "POST",
        "data": {"page": page}
      },
      {
        "url": "/search", // تلاش با GET
        "method": "GET",
        "query": {"search_type": "list", "page": page}
      },
      {
        "url": "/merchant/search", // اندپوینت جدید احتمالی
        "method": "POST",
        "data": {"page": page}
      }
    ];

    for (var ep in endpoints) {
      try {
        debugPrint("👉 Trying endpoint: ${ep['url']} (${ep['method']})");
        Response response;
        
        if (ep['method'] == 'POST') {
          response = await _client.post(ep['url'] as String, data: ep['data'] as Map<String, dynamic>);
        } else {
          response = await _client.get(ep['url'] as String, queryParameters: ep['query'] as Map<String, dynamic>);
        }

        // اگر موفق بود و لیست داشت
        final merchants = _parseMerchants(response.data);
        if (merchants.isNotEmpty) {
          debugPrint("✅ FOUND! Using endpoint: ${ep['url']}");
          return merchants;
        } else {
           debugPrint("⚠️ Endpoint returned empty list/bad format. Trying next...");
        }

      } catch (e) {
        debugPrint("❌ Failed: $e");
      }
    }

    // اگر همه شکست خوردند
    if (kIsWeb) return _getMockMerchants(); // برای وب ماک برگردان
    
    debugPrint("🛑 All endpoints failed.");
    return []; // برای موبایل لیست خالی (فعلا)
  }

  List<MerchantDto> _parseMerchants(dynamic data) {
    if (data == null) return [];
    try {
      List rawList = [];
      if (data['details'] is Map) {
         if (data['details']['list'] != null) rawList = data['details']['list'];
         else if (data['details']['data'] != null) rawList = data['details']['data'];
      } else if (data['details'] is List) {
        rawList = data['details'];
      }

      final List<MerchantDto> merchants = [];
      for (var item in rawList) {
        try {
          merchants.add(MerchantDto.fromJson(item));
        } catch (_) {}
      }
      return merchants;
    } catch (e) {
      return [];
    }
  }

  bool _isCorsError(DioException e) {
    return e.type == DioExceptionType.connectionError || 
           (e.message != null && e.message!.contains('XMLHttpRequest'));
  }

  // ... (متدهای Mock مثل قبل) ...
   Map<String, dynamic> _getMockHomeData() {
    return {
      "banners": [],
      "cuisines": []
    };
  }

  List<MerchantDto> _getMockMerchants() {
    return [
      MerchantDto(
        id: "101",
        name: "رستوران نمونه",
        logo: "",
        address: "آدرس تستی",
        rating: 4.5,
        deliveryFee: "15000",
        minOrder: "50000",
        isOpen: true,
      ),
    ];
  }
}