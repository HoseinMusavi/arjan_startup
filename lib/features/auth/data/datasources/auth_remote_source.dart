import '../../../../core/network/dio_client.dart';
import '../models/user_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<String> sendOtp(String mobile);
  Future<UserDto> verifyOtp(String mobile, String token, String code);
  Future<UserDto> register(String firstName, String lastName, String mobile, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;
  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<String> sendOtp(String mobile) async {
    final response = await _client.get(
      "/retrievePasswordBySMS",
      queryParameters: {"user_mobile": mobile},
    );
    return response.data['details']['forgot_password_token'];
  }

  @override
  Future<UserDto> verifyOtp(String mobile, String token, String code) async {
    bool isRegistrationToken = !token.contains('forgot') && token.length > 20;

    try {
      if (!isRegistrationToken) {
        debugPrint("DataSource: Verifying Login OTP...");
        await _client.get(
          "/changePasswordBySMS",
          queryParameters: {
            "forgot_password_token": token,
            "sms_code": code,
            "new_password": token,
          },
        );
      } else {
        debugPrint("DataSource: Verifying Registration OTP...");
        await _client.get(
          "/verifyRegistrationCode",
          queryParameters: {
            "client_token": token,
            "verification_code": code,
          },
        );
      }
      
      // اگر سرور تایید کرد، لاگین نهایی انجام می‌شود
      return await _loginAfterReset(mobile, token);
      
    } on DioException catch (e) {
      // ۱. اگر خطای واقعی از سمت سرور باشد (مثلاً کد اشتباه است)
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      
      // ۲. اگر خطای CORS در مرورگر رخ داد (مخصوص وب)
      if (kIsWeb && (e.type == DioExceptionType.connectionError || e.message!.contains('XMLHttpRequest'))) {
        debugPrint("DataSource: CORS Error in Web. Using Development Logic...");
        
        // --- کد طلایی برای تست در مرورگر ---
        // فقط اگر کد 123456 وارد شد اجازه ورود بده، در غیر این صورت خطا بده
        if (code == "123456") {
          debugPrint("DataSource: Master Code accepted for Web Testing.");
          return _generateFakeUser(mobile, token);
        } else {
          debugPrint("DataSource: Wrong Code in Web Test.");
          throw ServerException(message: "کد وارد شده صحیح نیست (در محیط وب کد 123456 را بزنید)", code: 2);
        }
      }
      
      rethrow;
    }
  }

  @override
  Future<UserDto> register(String firstName, String lastName, String mobile, String password) async {
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
      },
    );

    if (response.data['code'] == 1) {
      final String customerToken = response.data['details']['customer_token'] ?? "";
      return _generateFakeUser(mobile, customerToken);
    } else {
      throw ServerException(
        message: response.data['msg'] ?? "خطا در ثبت‌نام",
        code: response.data['code'],
      );
    }
  }

  Future<UserDto> _loginAfterReset(String mobile, String password) async {
    final response = await _client.get(
      "/login",
      queryParameters: {
        "email_address": mobile,
        "password": password,
        "device_uiid": "device_01231",
        "device_platform": "android"
      },
    );
    return UserDto.fromJson(response.data['details']);
  }

  UserDto _generateFakeUser(String mobile, String token) {
    return UserDto(
      id: "1", firstName: "کاربر", lastName: "تست",
      email: "$mobile@arjanapp.ir", token: token, phone: mobile,
    );
  }
}