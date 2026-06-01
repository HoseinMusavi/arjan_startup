import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<String> requestOtp(String mobile);
  Future<UserDto> verifyOtp(String mobile, String otp, String token);
  Future<UserDto> createAccount({
    required String firstName,
    required String lastName,
    required String mobile,
    required double lat,
    required double lng,
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

  // ✅ اضافه شده: ثبت‌نام کاربر جدید
  @override
  Future<UserDto> createAccount({
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
          "next_step": "map_select_location",
          "first_name": firstName,
          "last_name": lastName,
          "contact_phone": mobile,
          "check_terms_condition": "1",
          "device_id": "device_01231",
          "device_platform": "android",
          "device_uiid": "uiid_01234561",
          "code_version": "1.5",
          "api_key": "OOMW8CGDJJDRW3NBSABe3K26F7HQ75VGN",
          "lang": "ir",
          "lat": lat.toString(),
          "lng": lng.toString(),
          "current_page": "create_account",
        },
      );

      debugPrint("📡 [API] پاسخ createAccount: ${response.data}");
      
      final code = response.data['code'];
      final msg = response.data['msg'] ?? '';

      if (code == 1) {
        debugPrint("✅ [API] ثبت‌نام موفق - در حال پارس کردن UserDto");
        final userData = UserDto.fromJson(response.data);
        return userData;
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
}