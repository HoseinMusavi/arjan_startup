import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_dto.dart';

abstract class AuthRemoteDataSource {
  // درخواست ارسال کد OTP (بررسی شماره)
  Future<String> requestOtp(String mobile);
  
  // تایید کد OTP و دریافت توکن نهایی
  Future<UserDto> verifyOtp(String mobile, String otp, String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<String> requestOtp(String mobile) async {
    try {
      debugPrint("🔐 API Request: retrievePasswordBySMS for $mobile");
      
      final response = await _client.get(
        "/retrievePasswordBySMS",
        queryParameters: {
          "user_mobile": mobile,
          "device_platform": "android",
          "code_version": "1.5",
          "lang": "ir",
        },
      );

      if (response.data['code'] == 1) {
        final token = response.data['details']['forgot_password_token'];
        debugPrint("✅ OTP Sent. Token: $token");
        return token.toString();
      } else {
        throw ServerException(
          message: response.data['msg'] ?? "خطا در ارسال کد",
          code: response.data['code'],
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString(), code: 0);
    }
  }

  @override
  Future<UserDto> verifyOtp(String mobile, String otp, String token) async {
    try {
      debugPrint("🔐 API Request: changePasswordBySMS (Verifying OTP)...");

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

      if (response.data['code'] == 1) {
        debugPrint("✅ Login Success. Parsing User Data...");
        final userData = UserDto.fromJson(response.data);
        return userData;
      } else {
        throw ServerException(
          message: response.data['msg'] ?? "کد وارد شده اشتباه است",
          code: response.data['code'],
        );
      }
    } catch (e) {
      debugPrint("❌ Verify Error: $e");
      throw ServerException(message: "خطا در برقراری ارتباط با سرور", code: 0);
    }
  }
}