import 'dart:developer';
import 'package:arjan_startup/core/network/dio_client.dart';
import 'package:flutter/widgets.dart';
import '../models/cart_models.dart';
import '../models/cart_details_dto.dart';
import '../models/address_model.dart';
import '../models/delivery_time_model.dart';
import '../models/payment_method_model.dart';

abstract class CartRemoteDataSource {
  Future<CartCountDto> getCartCount(String merchantId, double lat, double lng);
  Future<AddToCartResponseDto> addToCart(Map<String, dynamic> payload);
  Future<void> clearCart(String merchantId);
  Future<CartDetailsDto> getCartDetails(String merchantId, double lat, double lng);
  Future<CartDetailsDto> getFirstCart(double lat, double lng);
  
  // APIهای جدید برای فرآیند پرداخت
  Future<List<AddressDto>> getAddressBookDropDown();
  Future<AddressResponseDto> setDeliveryAddress({
    required double lat,
    required double lng,
    required String street,
    required String city,
    required String state,
    required String zipcode,
    required String countryCode,
    required String locationName,
    required String contactPhone,
    required String merchantId,
  });
  Future<Map<String, String>> getDeliveryDateList(String merchantId);
  Future<Map<String, String>> getDeliveryTimeList(String merchantId, String deliveryDate);
  Future<RedeemPointsResponseDto> applyRedeemPoints(int points, String merchantId);
  Future<PreCheckoutResponseDto> preCheckout({
    required String transactionType,
    required String deliveryDate,
    required String deliveryTime,
    required String merchantId,
  });
  Future<PayNowResponseDto> payNow({
    required String transactionType,
    required String paymentProvider,
    required String deliveryDate,
    required String deliveryTime,
    required String merchantId,
  });
  Future<List<PaymentMethodDto>> getPaymentList(String merchantId, double lat, double lng);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final DioClient _dioClient;

  CartRemoteDataSourceImpl(this._dioClient);

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
      
      if (response.data['code'] == 1 && response.data['details'] != null) {
        return CartCountDto.fromJson(response.data['details']);
      }
      return CartCountDto(count: 0, basketCount: '0', basketTotal: '0 تومان');
    } catch (e) {
      log('❌ خطا در getCartCount: $e');
      return CartCountDto(count: 0, basketCount: '0', basketTotal: '0 تومان');
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
      final queryParams = {
        'merchant_id': merchantId,
        'transaction_type': 'delivery',
        ..._baseParams,
        'current_page': 'cart',
      };
      debugPrint('🗑️ [API] ارسال درخواست clearCart با GET برای merchant_id: $merchantId');
      final response = await _dioClient.get('/clearCart', queryParameters: queryParams);
      debugPrint('🗑️ [API] پاسخ clearCart: ${response.data}');
      
      if (response.data['code'] != 1) {
        throw Exception(response.data['msg'] ?? 'خطا در خالی کردن سبد');
      }
    } catch (e) {
      debugPrint('❌ [API] خطا در پاک کردن سبد خرید: $e');
      rethrow;
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
      } else if (response.data['code'] == 4) {
        log('⚠️ فروشگاه غیرفعال است (code 4) برای merchant_id: $merchantId');
        return CartDetailsDto(
          merchantName: '',
          merchantLogo: '',
          items: [],
          subtotal: 0,
          deliveryCharges: 0,
          total: 0,
          availablePoints: 0,
        );
      } else {
        return CartDetailsDto(
          merchantName: '',
          merchantLogo: '',
          items: [],
          subtotal: 0,
          deliveryCharges: 0,
          total: 0,
          availablePoints: 0,
        );
      }
    } catch (e) {
      log('❌ خطا در دریافت جزئیات فاکتور: $e');
      return CartDetailsDto(
        merchantName: '',
        merchantLogo: '',
        items: [],
        subtotal: 0,
        deliveryCharges: 0,
        total: 0,
        availablePoints: 0,
      );
    }
  }

  @override
    @override
  Future<CartDetailsDto> getFirstCart(double lat, double lng) async {
    try {
      final queryParams = {
        'lat': lat,
        'lng': lng,
        ..._baseParams,
      };

      debugPrint('🛒 [API] درخواست getFirstCart با پارامترهای: $queryParams');
      final response = await _dioClient.get('/getFirstCart', queryParameters: queryParams);
      
      debugPrint('🛒 [API] پاسخ getFirstCart: ${response.data}');
      
      if (response.data['code'] == 1 && response.data['details'] != null) {
        final details = response.data['details'];
        final merchantId = details['merchant_id']?.toString() ?? '';
        final count = details['count'] ?? 0;
        
        debugPrint('🛒 [API] getFirstCart: merchant_id=$merchantId, count=$count');
        
        // ✅ getFirstCart فقط merchant_id و count برمیگردونه
        // merchantName رو برابر merchant_id قرار میدیم تا CartBloc بتونه تشخیص بده
        return CartDetailsDto(
          merchantName: merchantId.isNotEmpty ? merchantId : '',
          merchantLogo: '',
          items: [],
          subtotal: 0,
          deliveryCharges: 0,
          total: 0,
          availablePoints: 0,
        );
      } else {
        return CartDetailsDto(
          merchantName: '',
          merchantLogo: '',
          items: [],
          subtotal: 0,
          deliveryCharges: 0,
          total: 0,
          availablePoints: 0,
        );
      }
    } catch (e) {
      debugPrint('❌ [API] خطا در getFirstCart: $e');
      return CartDetailsDto(
        merchantName: '',
        merchantLogo: '',
        items: [],
        subtotal: 0,
        deliveryCharges: 0,
        total: 0,
        availablePoints: 0,
      );
    }
  }

  // ==================== APIهای جدید ====================

  @override
  Future<List<AddressDto>> getAddressBookDropDown() async {
    try {
      final queryParams = {
        ..._baseParams,
        'current_page': 'address_form_select',
      };
      
      final response = await _dioClient.get('/getAddressBookDropDown', queryParameters: queryParams);
      
      if (response.data['code'] == 1 && response.data['details']['data'] != null) {
        final List<dynamic> list = response.data['details']['data'];
        return list.map((e) => AddressDto.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      log('❌ خطا در دریافت آدرس‌ها: $e');
      return [];
    }
  }

  @override
  Future<AddressResponseDto> setDeliveryAddress({
    required double lat,
    required double lng,
    required String street,
    required String city,
    required String state,
    required String zipcode,
    required String countryCode,
    required String locationName,
    required String contactPhone,
    required String merchantId,
  }) async {
    try {
      final queryParams = {
        'lat': lat,
        'lng': lng,
        'mapbox_drag_map': 'true',
        'mapbox_drag_end': 'true',
        'street': street,
        'city': city,
        'state': state,
        'zipcode': zipcode,
        'country_code': countryCode,
        'location_name': locationName,
        'contact_phone': contactPhone,
        'delivery_instruction': '',
        'merchant_id': merchantId,
        ..._baseParams,
        'current_page': 'address_form',
      };
      
      final response = await _dioClient.get('/setDeliveryAddress', queryParameters: queryParams);
      
      if (response.data['code'] == 1) {
        return AddressResponseDto.fromJson(response.data['details']);
      }
      throw Exception(response.data['msg'] ?? 'خطا در ثبت آدرس');
    } catch (e) {
      throw Exception('خطا در ثبت آدرس: $e');
    }
  }

  @override
  Future<Map<String, String>> getDeliveryDateList(String merchantId) async {
    try {
      final queryParams = {
        'merchant_id': merchantId,
        ..._baseParams,
        'current_page': 'cart',
      };
      
      final response = await _dioClient.get('/deliveryDateList', queryParameters: queryParams);
      
      if (response.data['code'] == 1 && response.data['details']['data'] != null) {
        final Map<String, dynamic> data = response.data['details']['data'];
        return data.map((key, value) => MapEntry(key, value.toString()));
      }
      return {};
    } catch (e) {
      log('❌ خطا در دریافت تاریخ‌ها: $e');
      return {};
    }
  }

  @override
  Future<Map<String, String>> getDeliveryTimeList(String merchantId, String deliveryDate) async {
    try {
      final queryParams = {
        'merchant_id': merchantId,
        'delivery_date': deliveryDate,
        ..._baseParams,
        'current_page': 'cart',
      };
      
      final response = await _dioClient.get('/deliveryTimeList', queryParameters: queryParams);
      
      if (response.data['code'] == 1 && response.data['details']['data'] != null) {
        final Map<String, dynamic> data = response.data['details']['data'];
        return data.map((key, value) => MapEntry(key, value.toString()));
      }
      return {};
    } catch (e) {
      log('❌ خطا در دریافت ساعات: $e');
      return {};
    }
  }

  @override
  Future<RedeemPointsResponseDto> applyRedeemPoints(int points, String merchantId) async {
    try {
      final queryParams = {
        'points': points,
        'merchant_id': merchantId,
        'transaction_type': 'delivery',
        ..._baseParams,
        'current_page': 'cart',
      };
      
      final response = await _dioClient.get('/applyRedeemPoints', queryParameters: queryParams);
      
      if (response.data['code'] == 1) {
        return RedeemPointsResponseDto.fromJson(response.data);
      }
      return RedeemPointsResponseDto(success: false, message: response.data['msg'] ?? 'خطا در اعمال امتیاز');
    } catch (e) {
      return RedeemPointsResponseDto(success: false, message: 'خطا در اعمال امتیاز');
    }
  }

  @override
  Future<PreCheckoutResponseDto> preCheckout({
    required String transactionType,
    required String deliveryDate,
    required String deliveryTime,
    required String merchantId,
  }) async {
    try {
      final queryParams = {
        'transaction_type': transactionType,
        'delivery_date': deliveryDate,
        'delivery_time': deliveryTime,
        'merchant_id': merchantId,
        ..._baseParams,
        'current_page': 'cart',
      };
      
      final response = await _dioClient.get('/preCheckout', queryParameters: queryParams);
      
      return PreCheckoutResponseDto.fromJson(response.data);
    } catch (e) {
      throw Exception('خطا در پیش‌تایید سفارش: $e');
    }
  }

  @override
  Future<PayNowResponseDto> payNow({
    required String transactionType,
    required String paymentProvider,
    required String deliveryDate,
    required String deliveryTime,
    required String merchantId,
  }) async {
    try {
      debugPrint('💳 [API] ارسال درخواست payNow:');
      debugPrint('   - transaction_type: $transactionType');
      debugPrint('   - payment_provider: $paymentProvider');
      debugPrint('   - delivery_date: $deliveryDate');
      debugPrint('   - delivery_time: $deliveryTime');
      debugPrint('   - merchant_id: $merchantId');
      
      final queryParams = {
        'transaction_type': transactionType,
        'payment_provider': paymentProvider,
        'delivery_date': deliveryDate,
        'delivery_time': deliveryTime,
        'sms_order_session': 'undefined',
        'delivery_asap': 'false',
        'merchant_id': merchantId,
        ..._baseParams,
        'current_page': 'payment_option',
      };
      
      debugPrint('💳 [API] پارامترهای نهایی: $queryParams');
      
      final response = await _dioClient.get('/payNow', queryParameters: queryParams);
      
      debugPrint('💳 [API] پاسخ دریافتی: code=${response.data['code']}, msg=${response.data['msg']}');
      
      return PayNowResponseDto.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ [API] خطا در payNow: $e');
      throw Exception('خطا در ثبت سفارش: $e');
    }
  }

  @override
  Future<List<PaymentMethodDto>> getPaymentList(String merchantId, double lat, double lng) async {
    try {
      final queryParams = {
        'transaction_type': 'delivery',
        'merchant_id': merchantId,
        ..._baseParams,
        'current_page': 'payment_option',
        'lat': lat,
        'lng': lng,
      };
      
      debugPrint('💳 [API] دریافت لیست روش‌های پرداخت با پارامترهای: $queryParams');
      final response = await _dioClient.get('/loadPaymentList', queryParameters: queryParams);
      
      debugPrint('💳 [API] پاسخ loadPaymentList: ${response.data}');
      
      if (response.data['code'] == 1 && response.data['details']['data'] != null) {
        final List<dynamic> list = response.data['details']['data'];
        return list.map((e) => PaymentMethodDto.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ [API] خطا در دریافت روش‌های پرداخت: $e');
      return [];
    }
  }
}