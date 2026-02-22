import 'dart:developer';
import '../../../../core/network/dio_client.dart';
import '../models/restaurant_info_dto.dart';
import '../models/menu_category_dto.dart';
import '../models/menu_item_dto.dart';

abstract class RestaurantRemoteDataSource {
  Future<RestaurantInfoDto?> getRestaurantInfo(String merchantId, double lat, double lng);
  Future<List<MenuCategoryDto>> getMenuCategories(String merchantId, double lat, double lng);
  Future<List<MenuItemDto>> getItemsByCategory(String merchantId, String categoryId, double lat, double lng);
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final DioClient _dioClient;

  RestaurantRemoteDataSourceImpl(this._dioClient);

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
}