import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<String> requestOtp(String mobile);
  Future<UserDto> verifyOtp(String mobile, String otp, String token);
  Future<Map<String, dynamic>> createAccount({
    required String firstName,
    required String lastName,
    required String mobile,
    required double lat,
    required double lng,
  });
  Future<UserDto> verifyAccount({
    required String mobile,
    required String otp,
    required String customerToken,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<String> requestOtp(String mobile) async {
    try {
      debugPrint("🔐 [API] درخواست OTP برای شماره: $mobile");
      
      final response = await _client.get(
        "/retrievePasswordBySMS",
        queryParameters: {
          "user_mobile": mobile,
          "device_platform": "android",
          "code_version": "1.5",
          "lang": "ir",
        },
      );

      debugPrint("📡 [API] پاسخ retrievePasswordBySMS: ${response.data}");
      
      final code = response.data['code'];
      final msg = response.data['msg'] ?? '';
      
      if (code == 1) {
        final token = response.data['details']?['forgot_password_token'];
        if (token == null) {
          debugPrint("❌ [API] توکن در پاسخ وجود ندارد!");
          throw ServerException(
            message: "خطا در دریافت توکن",
            code: code,
          );
        }
        debugPrint("✅ [API] OTP ارسال شد. Token: $token");
        return token.toString();
      } else {
        debugPrint("❌ [API] خطا در ارسال OTP: $msg (code: $code)");
        throw ServerException(
          message: msg,
          code: code,
        );
      }
    } catch (e) {
      debugPrint("❌ [API] خطای غیرمنتظره در requestOtp: $e");
      throw ServerException(message: e.toString(), code: 0);
    }
  }

  @override
  Future<UserDto> verifyOtp(String mobile, String otp, String token) async {
    try {
      debugPrint("🔐 [API] تایید OTP برای شماره: $mobile");
      debugPrint("   - token: $token");
      debugPrint("   - sms_code: $otp");

      final response = await _client.get(
        "/changePasswordBySMS",
        queryParameters: {
          "forgot_password_token": token,
          "sms_code": otp,
          "new_password": token,
          "device_platform": "android",
          "lang": "ir",
        },
      );

      debugPrint("📡 [API] پاسخ changePasswordBySMS (خام): ${response.data}");
      
      final code = response.data['code'];
      final msg = response.data['msg'] ?? '';

      if (code == 1) {
        if (msg.contains('فعال نیست') || 
            msg.contains('active') || 
            msg.contains('کاربر')) {
          debugPrint("⚠️ [API] با وجود code=1، پیام خطا دریافت شد: $msg");
          throw ServerException(
            message: msg,
            code: code,
          );
        }
        
        debugPrint("✅ [API] تایید OTP موفق - در حال پارس کردن UserDto");
        
        if (response.data['details'] == null) {
          debugPrint("❌ [API] details در پاسخ وجود ندارد!");
          throw ServerException(
            message: "پاسخ سرور ناقص است",
            code: code,
          );
        }
        
        final userData = UserDto.fromJson(response.data);
        debugPrint("✅ [API] UserDto ساخته شد: token=${userData.token.substring(0, userData.token.length > 10 ? 10 : userData.token.length)}...");
        return userData;
      } else {
        debugPrint("❌ [API] خطا در تایید OTP: $msg (code: $code)");
        throw ServerException(
          message: msg,
          code: code,
        );
      }
    } catch (e) {
      debugPrint("❌ [API] خطای غیرمنتظره در verifyOtp: $e");
      if (e is ServerException) rethrow;
      throw ServerException(message: "خطا در برقراری ارتباط با سرور", code: 0);
    }
  }

  @override
  Future<Map<String, dynamic>> createAccount({
    required String firstName,
    required String lastName,
    required String mobile,
    required double lat,
    required double lng,
  }) async {
    try {
      debugPrint("📝 [API] درخواست ثبت‌نام کاربر: $firstName $lastName, شماره: $mobile");
      
      final response = await _client.post(
        "/createAccount",
        data: {
          "first_name": firstName,
          "last_name": lastName,
          "contact_phone": mobile,
          "check_terms_condition": "1",
          "device_id": "device_01231",
          "device_platform": "android",
          "device_uiid": "uiid_01234561",
          "code_version": "1.5",
          "api_key": AppConstants.apiKey,
          "lang": "ir",
          "lat": lat.toString(),
          "lng": lng.toString(),
          "step": "finalize",
          "auto_activate": "1",
        },
      );

      debugPrint("📡 [API] پاسخ createAccount: ${response.data}");
      
      final code = response.data['code'];
      final msg = response.data['msg'] ?? '';

      if (code == 1) {
        debugPrint("✅ [API] ثبت‌نام اولیه موفق");
        
        final details = response.data['details'] ?? {};
        final customerToken = details['customer_token'] ?? '';
        final contactPhone = details['contact_phone'] ?? mobile;
        
        debugPrint("📱 [API] customer_token: $customerToken");
        debugPrint("📱 [API] contact_phone: $contactPhone");
        
        return {
          'customer_token': customerToken,
          'contact_phone': contactPhone,
          'message': msg,
          'raw_response': response.data,
        };
      } else {
        debugPrint("❌ [API] خطا در ثبت‌نام: $msg (code: $code)");
        throw ServerException(
          message: msg,
          code: code,
        );
      }
    } catch (e) {
      debugPrint("❌ [API] خطای غیرمنتظره در createAccount: $e");
      if (e is ServerException) rethrow;
      throw ServerException(message: "خطا در برقراری ارتباط با سرور", code: 0);
    }
  }

  @override
  Future<UserDto> verifyAccount({
    required String mobile,
    required String otp,
    required String customerToken,
  }) async {
    try {
      debugPrint("🔐 [API] تایید ثبت‌نام برای شماره: $mobile");
      debugPrint("   - customer_token: $customerToken");
      debugPrint("   - otp: $otp");

      // ✅ استفاده از متد صحیح verifyCode مطابق با کنترلر PHP
      debugPrint("📡 [API] ارسال درخواست به verifyCode...");
      
      final response = await _client.get(
        "/verifyCode",
        queryParameters: {
          "verification_type": "verification_mobile",
          "customer_token": customerToken,
          "code": otp,
          "device_platform": "android",
          "lang": "ir",
          "api_key": AppConstants.apiKey,
        },
      );

      debugPrint("📡 [API] پاسخ verifyCode: ${response.data}");
      
      final code = response.data['code'];
      final msg = response.data['msg'] ?? '';

      if (code == 1) {
        debugPrint("✅ [API] تایید ثبت‌نام با verifyCode موفق");
        
        // دریافت توکن جدید از پاسخ
        final details = response.data['details'] ?? {};
        final newToken = details['token'] ?? '';
        
        if (newToken.isEmpty) {
          debugPrint("⚠️ [API] توکن در پاسخ وجود ندارد!");
          throw ServerException(
            message: "پاسخ سرور ناقص است",
            code: code,
          );
        }
        
        debugPrint("🔑 [API] توکن جدید: ${newToken.substring(0, newToken.length > 10 ? 10 : newToken.length)}...");
        
        // ساخت UserDto با توکن جدید
        final userData = UserDto(
          token: newToken,
          firstName: '', // اطلاعات کامل از API بعدی دریافت میشه
          lastName: '',
          phone: mobile,
        );
        
        debugPrint("✅ [API] UserDto ساخته شد: token=${userData.token.substring(0, userData.token.length > 10 ? 10 : userData.token.length)}...");
        return userData;
        
      } else {
        debugPrint("❌ [API] خطا در تایید ثبت‌نام: $msg (code: $code)");
        throw ServerException(
          message: msg,
          code: code,
        );
      }
      
    } catch (e) {
      debugPrint("❌ [API] خطای غیرمنتظره در verifyAccount: $e");
      if (e is ServerException) rethrow;
      throw ServerException(message: "خطا در برقراری ارتباط با سرور", code: 0);
    }
  }
}