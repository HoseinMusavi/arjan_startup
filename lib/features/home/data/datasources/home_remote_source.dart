import 'dart:developer';
import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/session_service.dart';
import '../models/merchant_dto.dart';
import '../models/cuisine_dto.dart';
import '../models/search_response_dto.dart';
import '../models/promo_item_dto.dart';

abstract class HomeRemoteDataSource {
  Future<List<MerchantDto>> getMerchants(
    String searchType,
    double lat,
    double lng, {
    String? cuisineId,
  });

  Future<List<MerchantDto>> getMerchantsByBanner({
    required String bannerId,
    required double lat,
    required double lng,
  });

  Future<List<MerchantDto>> getFavoriteMerchants({
    required double lat,
    required double lng,
  });

  Future<List<CuisineDto>> getCuisines(double lat, double lng);
  Future<List<String>> getBanners();

  Future<SearchResponseDto> searchMerchantFood({
    required String query,
    required double lat,
    required double lng,
  });

  Future<PromoResponseDto> getFoodPromo({
    required double lat,
    required double lng,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _dioClient;
  final SessionService _sessionService;

  HomeRemoteDataSourceImpl(this._dioClient, this._sessionService);

  @override
  Future<List<MerchantDto>> getMerchants(
    String searchType,
    double lat,
    double lng, {
    String? cuisineId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'search_type': searchType,
        'lat': lat,
        'lng': lng,
        'with_distance': '1',
      };
      if (cuisineId != null && cuisineId.isNotEmpty) {
        queryParams['cuisine_id'] = cuisineId;
      }
      log('📡 [API] درخواست getMerchants: searchType=$searchType, cuisineId=$cuisineId');
      final response = await _dioClient.get('/searchMerchant', queryParameters: queryParams);
      final data = response.data;
      if (data['code'] == 2) return [];
      if (data['code'] == 1 && data['details'] != null && data['details']['list'] != null) {
        final List<dynamic> list = data['details']['list'];
        log('✅ [API] دریافت ${list.length} فروشگاه برای searchType=$searchType');
        return list.map<MerchantDto>((json) => MerchantDto.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      log('🔴 Error getMerchants ($searchType): $e');
      return [];
    }
  }

  @override
  Future<List<MerchantDto>> getMerchantsByBanner({
    required String bannerId,
    required double lat,
    required double lng,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'search_type': 'ByTag',
        'with_distance': '1',
        'sort_by': '',
        'banner_id': bannerId,
        'lat': lat,
        'lng': lng,
        'current_page': 'restaurant_list',
      };
      log('📡 [API] درخواست getMerchantsByBanner: bannerId=$bannerId');
      final response = await _dioClient.get('/searchMerchant', queryParameters: queryParams);
      final data = response.data;
      if (data['code'] == 2) return [];
      if (data['code'] == 1 && data['details'] != null && data['details']['list'] != null) {
        final List<dynamic> list = data['details']['list'];
        log('✅ [API] دریافت ${list.length} فروشگاه برای بنر $bannerId');
        return list.map<MerchantDto>((json) => MerchantDto.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      log('🔴 Error getMerchantsByBanner: $e');
      return [];
    }
  }

  @override
  Future<List<MerchantDto>> getFavoriteMerchants({
    required double lat,
    required double lng,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'search_type': 'favorites',
        'with_distance': '1',
        'sort_by': '',
        'lat': lat,
        'lng': lng,
        'current_page': 'restaurant_list',
      };
      log('⭐ [API] درخواست فروشگاه‌های مورد علاقه');
      final response = await _dioClient.get('/searchMerchant', queryParameters: queryParams);
      final data = response.data;
      if (data['code'] == 2) return [];
      if (data['code'] == 1 && data['details'] != null && data['details']['list'] != null) {
        final List<dynamic> list = data['details']['list'];
        log('✅ [API] دریافت ${list.length} فروشگاه مورد علاقه');
        return list.map<MerchantDto>((json) => MerchantDto.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      log('🔴 Error getFavoriteMerchants: $e');
      return [];
    }
  }

  @override
  Future<List<CuisineDto>> getCuisines(double lat, double lng) async {
    try {
      final response = await _dioClient.get('/cuisineList', queryParameters: {'carousel': '1', 'lat': lat, 'lng': lng});
      final data = response.data;
      if (data['code'] == 1 && data['details'] != null && data['details']['list'] != null) {
        final List<dynamic> list = data['details']['list'];
        log('🟢 Cuisines Fetched: ${list.length}');
        return list.map<CuisineDto>((e) => CuisineDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      log('🔴 Error getCuisines: $e');
      return [];
    }
  }

  @override
  Future<List<String>> getBanners() async {
    try {
      final response = await _dioClient.get('/getSettings');
      final data = response.data;
      if (data['code'] == 1 && data['details'] != null) {
        final details = data['details'];
        if (details['settings'] != null && details['settings']['home_banner'] != null) {
          final List<dynamic> bannersRaw = details['settings']['home_banner'];
          return bannersRaw.map((e) => e.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      log('🔴 Error getBanners: $e');
      return [];
    }
  }

  @override
  Future<SearchResponseDto> searchMerchantFood({
    required String query,
    required double lat,
    required double lng,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'search_string': query,
        'device_id': _sessionService.deviceId,
        'device_platform': 'android',
        'device_uiid': _sessionService.deviceUiid,
        'code_version': '1.5',
        'user_token': _sessionService.userToken,
        'lang': 'ir',
        'lat': lat,
        'lng': lng,
        'current_page': 'search_form',
      };
      log('🔍 [API] جستجو: "$query"');
      final response = await _dioClient.get('/searchMerchantFood', queryParameters: params);
      final searchResponse = SearchResponseDto.fromJson(response.data);
      log('✅ [API] تعداد نتایج: ${searchResponse.items.length}');
      return searchResponse;
    } catch (e, stack) {
      log('❌ [API] خطا در جستجو: $e\n$stack');
      return SearchResponseDto(code: 0, msg: 'خطا در ارتباط با سرور', items: const []);
    }
  }

  @override
  Future<PromoResponseDto> getFoodPromo({
    required double lat,
    required double lng,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'sort_fields': 'discount',
        'sort_by': 'DESC',
        'infinite_done': '0',
        'device_id': _sessionService.deviceId,
        'device_platform': 'android',
        'device_uiid': _sessionService.deviceUiid,
        'code_version': '1.5',
        'user_token': _sessionService.userToken,
        'lang': 'ir',
        'lat': lat,
        'lng': lng,
        'current_page': 'promo_food_list',
      };
      log('🎁 [API] درخواست تخفیف‌ها');
      final response = await _dioClient.get('/foodPromo', queryParameters: params);
      final promoResponse = PromoResponseDto.fromJson(response.data);
      log('✅ [API] تعداد تخفیف‌ها: ${promoResponse.items.length}');
      return promoResponse;
    } catch (e, stack) {
      log('❌ [API] خطا در دریافت تخفیف‌ها: $e\n$stack');
      return PromoResponseDto(code: 0, msg: 'خطا', items: []);
    }
  }
}