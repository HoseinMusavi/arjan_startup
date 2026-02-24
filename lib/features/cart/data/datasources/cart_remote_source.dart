import 'dart:developer';
import 'package:arjan_startup/core/network/dio_client.dart';
import '../models/cart_models.dart';
import '../models/cart_details_dto.dart';

abstract class CartRemoteDataSource {
  Future<CartCountDto> getCartCount(String merchantId, double lat, double lng);
  Future<AddToCartResponseDto> addToCart(Map<String, dynamic> payload);
  Future<void> clearCart(String merchantId);
  Future<CartDetailsDto> getCartDetails(String merchantId, double lat, double lng);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final DioClient _dioClient;

  CartRemoteDataSourceImpl(this._dioClient);

  // پارامترهای ثابت طبق لاگ شما
  final Map<String, dynamic> _baseParams = {
    'device_id': 'device_01231',
    'device_platform': 'android',
    'device_uiid': 'uiid_01234561',
    'code_version': '1.5',
    'user_token': '9htacgzgjangzcv8211689d1f2b470ca46cbb4ba756aa27',
  };

  @override
  Future<CartCountDto> getCartCount(String merchantId, double lat, double lng) async {
    try {
      final data = {'merchant_id': merchantId, 'lat': lat, 'lng': lng, ..._baseParams};
      final response = await _dioClient.post('/getCartCount/', data: data);
      
      if (response.data['details'] != null && response.data['details'] is Map) {
        return CartCountDto.fromJson(response.data['details']);
      }
      return CartCountDto(count: 0, basketCount: '0', basketTotal: '0 تومان');
    } catch (e) {
      throw Exception('خطا در دریافت اطلاعات سبد خرید');
    }
  }

  @override
  Future<AddToCartResponseDto> addToCart(Map<String, dynamic> payload) async {
    try {
      final data = {...payload, ..._baseParams};
      final response = await _dioClient.post('/addToCart', data: data);
      
      if (response.data['code'] == 1) {
        return AddToCartResponseDto.fromJson(response.data);
      } else {
        throw Exception(response.data['msg'] ?? 'خطا در افزودن به سبد');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  @override
  Future<void> clearCart(String merchantId) async {
    try {
      final data = {'merchant_id': merchantId, ..._baseParams};
      await _dioClient.post('/clearCart', data: data); 
    } catch (e) {
      log('❌ خطا در پاک کردن سبد خرید: $e');
    }
  }

  @override
  Future<CartDetailsDto> getCartDetails(String merchantId, double lat, double lng) async {
    try {
      final queryParams = {
        'merchant_id': merchantId,
        'lat': lat,
        'lng': lng,
        'current_page': 'cart',
        ..._baseParams,
      };

      final response = await _dioClient.get('/loadCart', queryParameters: queryParams);
      
      if (response.data['code'] == 1 && response.data['details'] != null) {
        return CartDetailsDto.fromJson(response.data['details']);
      } else {
        throw Exception(response.data['msg'] ?? 'سبد خرید شما خالی است');
      }
    } catch (e) {
      throw Exception('خطا در دریافت جزئیات فاکتور');
    }
  }
}