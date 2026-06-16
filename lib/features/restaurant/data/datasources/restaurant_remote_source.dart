import 'dart:developer';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/session_service.dart';
import '../models/restaurant_info_dto.dart';
import '../models/menu_category_dto.dart';
import '../models/menu_item_dto.dart';
import '../models/item_details_dto.dart';
import '../models/search_category_item_dto.dart';
import '../models/merchant_about_dto.dart';

abstract class RestaurantRemoteDataSource {
  Future<RestaurantInfoDto?> getRestaurantInfo(String merchantId, double lat, double lng);
  Future<List<MenuCategoryDto>> getMenuCategories(String merchantId, double lat, double lng);
  Future<List<MenuItemDto>> getItemsByCategory(String merchantId, String categoryId, double lat, double lng);
  Future<ItemDetailsDto?> getItemDetails(String merchantId, String itemId, String categoryId, double lat, double lng);
  Future<SearchCategoryResponseDto> searchFoodCategory({
    required String query,
    required String merchantId,
    required double lat,
    required double lng,
  });
  Future<MerchantAboutDto> getMerchantAbout({
    required String merchantId,
    required double lat,
    required double lng,
  });
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final DioClient _dioClient;
  final SessionService _sessionService;

  RestaurantRemoteDataSourceImpl(this._dioClient, this._sessionService);

  @override
  Future<RestaurantInfoDto?> getRestaurantInfo(String merchantId, double lat, double lng) async {
    log('🌐 [API Call] درخواست دریافت اطلاعات رستوران (ID: $merchantId)');
    try {
      final response = await _dioClient.get(
        '/getRestaurantInfo',
        queryParameters: {'merchant_id': merchantId, 'lat': lat, 'lng': lng},
      );

      final data = response.data;
      if (data['code'] == 1 && data['details']?['data'] != null) {
        log('✅ [API Success] اطلاعات رستوران با موفقیت دریافت شد.');
        return RestaurantInfoDto.fromJson(data['details']['data']);
      } else {
        log('⚠️ [API Warning] کد ناموفق یا دیتای خالی در getRestaurantInfo: ${data['msg']}');
        return null;
      }
    } catch (e) {
      log('❌ [API Error] خطا در اتصال به سرور (getRestaurantInfo): $e');
      throw Exception('خطا در دریافت اطلاعات رستوران');
    }
  }

  @override
  Future<List<MenuCategoryDto>> getMenuCategories(String merchantId, double lat, double lng) async {
    log('🌐 [API Call] درخواست دریافت دسته‌بندی‌های منو (ID: $merchantId)');
    try {
      final response = await _dioClient.get(
        '/getMerchantMenu',
        queryParameters: {'merchant_id': merchantId, 'lat': lat, 'lng': lng},
      );

      final data = response.data;
      if (data['code'] == 1 && data['details']?['list'] != null) {
        final List<dynamic> list = data['details']['list'];
        log('✅ [API Success] تعداد ${list.length} دسته‌بندی منو یافت شد.');
        return list.map<MenuCategoryDto>((e) => MenuCategoryDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      log('⚠️ [API Warning] دسته‌بندی منویی یافت نشد.');
      return [];
    } catch (e) {
      log('❌ [API Error] خطا در دریافت دسته‌بندی‌های منو: $e');
      return [];
    }
  }

  @override
  Future<List<MenuItemDto>> getItemsByCategory(String merchantId, String categoryId, double lat, double lng) async {
    log('🌐 [API Call] درخواست غذاهای دسته‌بندی (CatID: $categoryId) برای رستوران (ID: $merchantId)');
    try {
      final response = await _dioClient.get(
        '/getItemByCategory',
        queryParameters: {'merchant_id': merchantId, 'cat_id': categoryId, 'lat': lat, 'lng': lng},
      );

      final data = response.data;
      if (data['code'] == 1 && data['details']?['data'] != null) {
        final List<dynamic> list = data['details']['data'];
        log('✅ [API Success] تعداد ${list.length} آیتم غذا یافت شد.');
        return list.map<MenuItemDto>((e) => MenuItemDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      log('⚠️ [API Warning] هیچ غذایی در این دسته‌بندی یافت نشد.');
      return [];
    } catch (e) {
      log('❌ [API Error] خطا در دریافت غذاهای دسته‌بندی: $e');
      return [];
    }
  }

  @override
  Future<ItemDetailsDto?> getItemDetails(String merchantId, String itemId, String categoryId, double lat, double lng) async {
    log('🌐 [API Call] درخواست جزئیات غذا (ItemID: $itemId) برای رستوران (ID: $merchantId)');
    try {
      final response = await _dioClient.get(
        '/itemDetails',
        queryParameters: {
          'merchant_id': merchantId,
          'item_id': itemId,
          'cat_id': categoryId,
          'lat': lat,
          'lng': lng,
        },
      );

      final data = response.data;
      if (data['code'] == 1 && data['details'] != null && data['details'] is Map<String, dynamic>) {
        log('✅ [API Success] جزئیات غذا با موفقیت دریافت شد.');
        return ItemDetailsDto.fromJson(data['details']);
      } else {
        log('⚠️ [API Warning] خطا در دریافت جزئیات غذا: ${data['msg']}');
        return null;
      }
    } catch (e) {
      log('❌ [API Error] خطا در دریافت جزئیات غذا: $e');
      return null;
    }
  }

  @override
  Future<SearchCategoryResponseDto> searchFoodCategory({
    required String query,
    required String merchantId,
    required double lat,
    required double lng,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'item_name': query,
        'merchant_id': merchantId,
        'device_id': _sessionService.deviceId,
        'device_platform': 'android',
        'device_uiid': _sessionService.deviceUiid,
        'code_version': '1.5',
        'user_token': _sessionService.userToken,
        'lang': 'ir',
        'lat': lat,
        'lng': lng,
        'current_page': 'search_category',
      };
      log('🔍 [API] جستجوی درون منو: "$query" در فروشگاه $merchantId');
      final response = await _dioClient.get('/searchFoodCategory', queryParameters: params);
      final searchResponse = SearchCategoryResponseDto.fromJson(response.data);
      log('✅ [API] تعداد دسته‌بندی‌های یافت شده: ${searchResponse.items.length}');
      return searchResponse;
    } catch (e, stack) {
      log('❌ [API] خطا در جستجوی منو: $e\n$stack');
      return SearchCategoryResponseDto(code: 0, msg: 'خطا در ارتباط با سرور', items: []);
    }
  }

  @override
  Future<MerchantAboutDto> getMerchantAbout({
    required String merchantId,
    required double lat,
    required double lng,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'merchant_id': merchantId,
        'device_id': _sessionService.deviceId,
        'device_platform': 'android',
        'device_uiid': _sessionService.deviceUiid,
        'code_version': '1.5',
        'user_token': _sessionService.userToken,
        'lang': 'ir',
        'lat': lat,
        'lng': lng,
        'current_page': 'about',
      };
      log('📋 [API] درخواست اطلاعات رستوران (درباره) برای فروشگاه: $merchantId');
      final response = await _dioClient.get('/GetMerchantAbout', queryParameters: params);
      final about = MerchantAboutDto.fromJson(response.data);
      log('✅ [API] اطلاعات درباره رستوران دریافت شد: ${about.data.restaurantName}');
      return about;
    } catch (e, stack) {
      log('❌ [API] خطا در دریافت اطلاعات درباره رستوران: $e\n$stack');
      return const MerchantAboutDto(
        code: 0,
        msg: 'خطا در ارتباط با سرور',
        data: MerchantAboutDataDto(
          merchantId: '',
          restaurantName: '',
          completeAddress: '',
          restaurantPhone: '',
          contactPhone: '',
          latitude: '',
          longitude: '',
          merchantTableBooking: '',
          cuisine: '',
          rating: RatingDto(ratings: 0, votes: 0),
          reviewCount: '0 نظر',
          opening: [],
          payment: [],
          information: '',
          website: '',
          services: '',
        ),
      );
    }
  }
}