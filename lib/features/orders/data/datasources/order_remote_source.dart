import 'dart:developer';
import 'package:arjan_startup/core/network/dio_client.dart';
import 'package:arjan_startup/core/services/session_service.dart';
import 'package:flutter/material.dart';
import '../models/order_models.dart';

abstract class OrderRemoteDataSource {
  Future<OrderListResponseDto> getOrderList(String tab, double lat, double lng);
  Future<OrderDetailResponseDto> getOrderDetail(String orderId, double lat, double lng);
  Future<ReOrderResponseDto> reOrder(String orderId, double lat, double lng);
  Future<TrackResponseDto> checkTrackHistory(String orderId, double lat, double lng);
  Future<OrderSearchResponseDto> searchOrder(String searchStr, double lat, double lng);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient _dioClient;
  final SessionService _sessionService;

  OrderRemoteDataSourceImpl(this._dioClient, this._sessionService);

  // ✅ توکن از SessionService گرفته میشه
  Map<String, dynamic> _getBaseParams() {
    final token = _sessionService.userToken;
    debugPrint('🔑 [OrderAPI] توکن فعلی: ${token.isNotEmpty ? token.substring(0, token.length > 10 ? 10 : token.length) : '(empty)'}...');
    
    return {
      'device_id': _sessionService.deviceId,
      'device_platform': 'android',
      'device_uiid': _sessionService.deviceUiid,
      'code_version': '1.5',
      'user_token': token,
    };
  }

  @override
  Future<OrderListResponseDto> getOrderList(String tab, double lat, double lng) async {
    try {
      final queryParams = {
        'tab': tab,
        ..._getBaseParams(),
        'current_page': 'tabbar',
        'lat': lat,
        'lng': lng,
      };

      debugPrint('📋 [OrderAPI] دریافت لیست سفارشات - tab: $tab');
      final response = await _dioClient.get('/OrderList', queryParameters: queryParams);
      debugPrint('📋 [OrderAPI] پاسخ دریافت شد - code: ${response.data['code']}');

      return OrderListResponseDto.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ [OrderAPI] خطا در دریافت لیست سفارشات: $e');
      return OrderListResponseDto(code: 0, message: 'خطا در دریافت اطلاعات');
    }
  }

  @override
  Future<OrderDetailResponseDto> getOrderDetail(String orderId, double lat, double lng) async {
    try {
      final queryParams = {
        'order_id': orderId,
        ..._getBaseParams(),
        'current_page': 'view_order',
        'lat': lat,
        'lng': lng,
      };

      debugPrint('📋 [OrderAPI] دریافت جزییات سفارش - orderId: $orderId');
      final response = await _dioClient.get('/ViewOrder', queryParameters: queryParams);
      debugPrint('📋 [OrderAPI] پاسخ دریافت شد - code: ${response.data['code']}');

      return OrderDetailResponseDto.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ [OrderAPI] خطا در دریافت جزییات سفارش: $e');
      return OrderDetailResponseDto(code: 0, message: 'خطا در دریافت اطلاعات');
    }
  }

  @override
  Future<ReOrderResponseDto> reOrder(String orderId, double lat, double lng) async {
    try {
      final queryParams = {
        'order_id': orderId,
        ..._getBaseParams(),
        'current_page': 'tabbar',
        'lat': lat,
        'lng': lng,
      };

      debugPrint('📋 [OrderAPI] ثبت مجدد سفارش - orderId: $orderId');
      final response = await _dioClient.get('/ReOrder', queryParameters: queryParams);
      debugPrint('📋 [OrderAPI] پاسخ دریافت شد - code: ${response.data['code']}');

      return ReOrderResponseDto.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ [OrderAPI] خطا در ثبت مجدد سفارش: $e');
      return ReOrderResponseDto(code: 0, message: 'خطا در ثبت مجدد', merchantId: '');
    }
  }

  @override
  Future<TrackResponseDto> checkTrackHistory(String orderId, double lat, double lng) async {
    try {
      final queryParams = {
        'order_id': orderId,
        ..._getBaseParams(),
        'current_page': 'track_history',
        'lat': lat,
        'lng': lng,
      };

      debugPrint('📋 [OrderAPI] بررسی وضعیت پیگیری سفارش - orderId: $orderId');
      final response = await _dioClient.get('/checkRunTrackHistory', queryParameters: queryParams);
      debugPrint('📋 [OrderAPI] پاسخ دریافت شد - code: ${response.data['code']}');

      return TrackResponseDto.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ [OrderAPI] خطا در بررسی پیگیری سفارش: $e');
      return TrackResponseDto(code: 0, message: 'خطا', runTrack: false);
    }
  }

  @override
  Future<OrderSearchResponseDto> searchOrder(String searchStr, double lat, double lng) async {
    try {
      final queryParams = {
        'search_str': searchStr,
        ..._getBaseParams(),
        'current_page': 'order_search',
        'lat': lat,
        'lng': lng,
      };

      debugPrint('📋 [OrderAPI] جستجوی سفارش - searchStr: $searchStr');
      final response = await _dioClient.get('/searchOrder', queryParameters: queryParams);
      debugPrint('📋 [OrderAPI] پاسخ دریافت شد - code: ${response.data['code']}');

      return OrderSearchResponseDto.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ [OrderAPI] خطا در جستجوی سفارش: $e');
      return OrderSearchResponseDto(code: 0, message: 'خطا', items: []);
    }
  }
}