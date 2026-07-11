import 'package:flutter/foundation.dart';
import 'package:arjan_startup/core/services/session_service.dart';
import 'package:arjan_startup/core/network/dio_client.dart';
import '../models/profile_dto.dart';
import '../models/point_summary_dto.dart';
import '../models/point_detail_dto.dart';
import '../models/address_dto.dart';
import '../models/notification_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileDto> getProfile({String? currentPage});
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String contactPhone,
    required String emailAddress,
    String? currentPage,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
    String? currentPage,
  });
  Future<List<PointSummaryDto>> getPointSummary({String? currentPage});
  Future<List<PointDetailDto>> getPointDetails({
    required String pointType,
    String? currentPage,
  });
  Future<List<AddressDto>> getAddressList({String? pageAction, String? currentPage});
  Future<void> saveAddress(Map<String, dynamic> addressData, {String? currentPage});
  Future<void> deleteAddress({required String id, String? currentPage});
  Future<List<NotificationDto>> getNotifications({String? currentPage});
  Future<Map<String, String>> getCountryList({String? currentPage});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _client;
  final SessionService _sessionService;

  static const String _apiKey = 'OOMW8CGDJJDRW3NBSABe3K26F7HQ75VGN';
  static const String _platform = 'android';
  static const String _codeVersion = '1.5';
  static const String _defaultLang = 'ir';
  static const String _defaultLat = '30.58966249878679';
  static const String _defaultLng = '50.25499014336867';

  ProfileRemoteDataSourceImpl(this._client, this._sessionService);

  Map<String, dynamic> _buildBaseParams({
    String? currentPage,
    String? action,
    String? pointType,
    String? id,
    String? pageAction,
    Map<String, dynamic>? extra,
  }) {
    final params = <String, dynamic>{
      'device_id': _sessionService.deviceId,
      'device_platform': _platform,
      'device_uiid': _sessionService.deviceUiid,
      'code_version': _codeVersion,
      'user_token': _sessionService.userToken,
      'api_key': _apiKey,
      'lang': _defaultLang,
      'lat': _defaultLat,
      'lng': _defaultLng,
    };

    if (currentPage != null && currentPage.isNotEmpty) {
      params['current_page'] = currentPage;
    }
    if (action != null && action.isNotEmpty) {
      params['action'] = action;
    }
    if (pointType != null && pointType.isNotEmpty) {
      params['point_type'] = pointType;
    }
    if (id != null && id.isNotEmpty) {
      params['id'] = id;
    }
    if (pageAction != null && pageAction.isNotEmpty) {
      params['page_action'] = pageAction;
    }
    if (extra != null) {
      params.addAll(extra);
    }

    return params;
  }

  // ==================== ۱. دریافت پروفایل ====================
  @override
  Future<ProfileDto> getProfile({String? currentPage = 'edit_profile'}) async {
    debugPrint('📡 [Profile] Calling getProfile API...');
    final params = _buildBaseParams(currentPage: currentPage);
    final response = await _client.get('/GetProfile', queryParameters: params);

    debugPrint('✅ [Profile] getProfile response code: ${response.data['code']}');
    return ProfileDto.fromJson(response.data);
  }

  // ==================== ۲. بروزرسانی پروفایل ====================
  @override
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String contactPhone,
    required String emailAddress,
    String? currentPage = 'edit_profile',
  }) async {
    debugPrint('📡 [Profile] Calling updateProfile API...');
    final params = _buildBaseParams(currentPage: currentPage);
    final data = {
      'first_name': firstName,
      'last_name': lastName,
      'contact_phone': contactPhone,
      'email_address': emailAddress,
      ...params,
    };

    final response = await _client.post('/UpdateProfile', data: data);
    debugPrint('✅ [Profile] updateProfile response code: ${response.data['code']}');
    if (response.data['code'] != 1) {
      throw Exception(response.data['msg'] ?? 'خطا در بروزرسانی پروفایل');
    }
  }

  // ==================== ۳. تغییر رمز عبور ====================
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
    String? currentPage = 'change_password',
  }) async {
    debugPrint('📡 [Profile] Calling changePassword API...');
    final params = _buildBaseParams(currentPage: currentPage);
    final data = {
      'current_password': currentPassword,
      'new_password': newPassword,
      'cnew_password': confirmNewPassword,
      ...params,
    };

    final response = await _client.post('/ChangePassword', data: data);
    debugPrint('✅ [Profile] changePassword response code: ${response.data['code']}');
    if (response.data['code'] != 1) {
      throw Exception(response.data['msg'] ?? 'خطا در تغییر رمز عبور');
    }
  }

  // ==================== ۴. دریافت خلاصه کیف پول ====================
  @override
  Future<List<PointSummaryDto>> getPointSummary({String? currentPage = 'points_list'}) async {
    debugPrint('📡 [Profile] Calling getPointSummary API...');
    final params = _buildBaseParams(currentPage: currentPage);
    final response = await _client.get('/GetPointSummary', queryParameters: params);

    debugPrint('✅ [Profile] getPointSummary response code: ${response.data['code']}');
    // ✅ مدیریت کد ۶ (هیچ نتیجه‌ای)
    if (response.data['code'] == 6) {
      debugPrint('📭 [Profile] getPointSummary: No data (code 6), returning empty list');
      return [];
    }
    final dataList = response.data['details']?['data'] as List? ?? [];
    return dataList.map((item) => PointSummaryDto.fromJson(item)).toList();
  }

  // ==================== ۵. دریافت جزئیات کیف پول ====================
  @override
  Future<List<PointDetailDto>> getPointDetails({
    required String pointType,
    String? currentPage = 'points_details',
  }) async {
    debugPrint('📡 [Profile] Calling getPointDetails API for type: $pointType');
    final params = _buildBaseParams(
      currentPage: currentPage,
      pointType: pointType,
    );
    final response = await _client.get('/GetPointDetails', queryParameters: params);

    debugPrint('✅ [Profile] getPointDetails response code: ${response.data['code']}');
    // ✅ مدیریت کد ۶ (هیچ نتیجه‌ای)
    if (response.data['code'] == 6) {
      debugPrint('📭 [Profile] getPointDetails: No data (code 6), returning empty list');
      return [];
    }
    final dataList = response.data['details']?['data'] as List? ?? [];
    return dataList.map((item) => PointDetailDto.fromJson(item)).toList();
  }

  // ==================== ۶. دریافت لیست آدرس‌ها ====================
  @override
  Future<List<AddressDto>> getAddressList({
    String? pageAction,
    String? currentPage = 'addressbook_list',
  }) async {
    debugPrint('📡 [Profile] Calling getAddressList API...');
    final params = _buildBaseParams(
      currentPage: currentPage,
      pageAction: pageAction,
    );
    final response = await _client.get('/AddressBookList', queryParameters: params);

    debugPrint('✅ [Profile] getAddressList response code: ${response.data['code']}');
    // ✅ مدیریت کد ۶ (هیچ نتیجه‌ای)
    if (response.data['code'] == 6) {
      debugPrint('📭 [Profile] getAddressList: No data (code 6), returning empty list');
      return [];
    }
    final dataList = response.data['details']?['data'] as List? ?? [];
    return dataList.map((item) => AddressDto.fromJson(item)).toList();
  }

  // ==================== ۷. ذخیره آدرس جدید ====================
  @override
  Future<void> saveAddress(Map<String, dynamic> addressData, {String? currentPage = 'address_book'}) async {
    debugPrint('📡 [Profile] Calling saveAddress API...');
    final params = _buildBaseParams(currentPage: currentPage);
    final data = {
      ...addressData,
      ...params,
    };

    final response = await _client.post('/saveAddressBook', data: data);
    debugPrint('✅ [Profile] saveAddress response code: ${response.data['code']}');
    if (response.data['code'] != 1) {
      throw Exception(response.data['msg'] ?? 'خطا در ذخیره آدرس');
    }
  }

  // ==================== ۸. حذف آدرس ====================
  @override
  Future<void> deleteAddress({required String id, String? currentPage = 'addressbook_list'}) async {
    debugPrint('📡 [Profile] Calling deleteAddress API for id: $id');
    final params = _buildBaseParams(
      currentPage: currentPage,
      id: id,
    );
    final response = await _client.get('/DeleteAddressBook', queryParameters: params);

    debugPrint('✅ [Profile] deleteAddress response code: ${response.data['code']}');
    if (response.data['code'] != 1) {
      throw Exception(response.data['msg'] ?? 'خطا در حذف آدرس');
    }
  }

  // ==================== ۹. دریافت لیست اعلان‌ها ====================
  @override
  Future<List<NotificationDto>> getNotifications({String? currentPage = 'notifications'}) async {
    debugPrint('📡 [Profile] Calling getNotifications API...');
    final params = _buildBaseParams(currentPage: currentPage);
    final response = await _client.get('/GetNotifications', queryParameters: params);

    debugPrint('✅ [Profile] getNotifications response code: ${response.data['code']}');
    // ✅ مدیریت کد ۶ (هیچ نتیجه‌ای)
    if (response.data['code'] == 6) {
      debugPrint('📭 [Profile] getNotifications: No data (code 6), returning empty list');
      return [];
    }
    final dataList = response.data['details']?['data'] as List? ?? [];
    return dataList.map((item) => NotificationDto.fromJson(item)).toList();
  }

  // ==================== ۱۰. دریافت لیست کشورها ====================
  @override
  Future<Map<String, String>> getCountryList({String? currentPage = 'address_book'}) async {
    debugPrint('📡 [Profile] Calling getCountryList API...');
    final params = _buildBaseParams(currentPage: currentPage);
    final response = await _client.get('/getCountryList', queryParameters: params);

    debugPrint('✅ [Profile] getCountryList response code: ${response.data['code']}');
    final countryList = response.data['details']?['country_list'] as Map<String, dynamic>? ?? {};
    return Map<String, String>.from(countryList.map((key, value) => MapEntry(key, value.toString())));
  }
}