import 'dart:developer';
import 'package:arjan_startup/core/network/dio_client.dart';
import '../models/cart_models.dart';

abstract class CartRemoteDataSource {
  Future<CartCountDto> getCartCount(String merchantId, double lat, double lng);
  Future<AddToCartResponseDto> addToCart(Map<String, dynamic> payload);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final DioClient _dioClient;

  CartRemoteDataSourceImpl(this._dioClient);

  @override
  Future<CartCountDto> getCartCount(String merchantId, double lat, double lng) async {
    log('🛒 [Cart API] دریافت موجودی سبد خرید برای فروشگاه: $merchantId');
    try {
      final response = await _dioClient.post(
        '/getCartCount', 
        data: {'merchant_id': merchantId, 'lat': lat, 'lng': lng},
      );
      
      if (response.data['details'] != null) {
        return CartCountDto.fromJson(response.data['details']);
      }
      return CartCountDto(count: 0, basketCount: '0', basketTotal: '0 تومان');
    } catch (e) {
      log('❌ [Cart API Error] خطا: $e');
      throw Exception('خطا در دریافت اطلاعات سبد خرید');
    }
  }

  @override
  Future<AddToCartResponseDto> addToCart(Map<String, dynamic> payload) async {
    log('🛒 [Cart API] افزودن آیتم به سبد خرید...');
    try {
      final response = await _dioClient.post('/addToCart', data: payload);
      
      if (response.data['code'] == 1) {
        log('✅ [Cart API] موفقیت آمیز');
        return AddToCartResponseDto.fromJson(response.data);
      } else {
        throw Exception(response.data['msg'] ?? 'خطا');
      }
    } catch (e) {
      log('❌ [Cart API Error] خطا: $e');
      throw Exception('خطا در ارتباط با سرور');
    }
  }
}