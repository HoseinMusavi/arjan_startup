import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_dto.dart';

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
      queryParameters: {
        "user_mobile": mobile,
      },
    );
    // استخراج توکن فراموشی رمز از پاسخ سرور
    return response.data['details']['forgot_password_token'];
  }

  @override
  Future<UserDto> verifyOtp(String mobile, String token, String code) async {
    // مرحله ۱: تغییر رمز عبور با کد پیامک شده
    // ما توکن را به عنوان رمز جدید ست می‌کنیم تا فقط پروسه لاگین تکمیل شود
    await _client.get(
      "/changePasswordBySMS",
      queryParameters: {
        "forgot_password_token": token,
        "sms_code": code,
        "new_password": token,
      },
    );
    
    // مرحله ۲: لاگین خودکار با رمز جدید (که همان توکن است)
    return _loginAfterReset(mobile, token);
  }
  
  @override
  Future<UserDto> register(String firstName, String lastName, String mobile, String password) async {
    final response = await _client.post(
      "/createAccount",
      data: {
        "first_name": firstName,
        "last_name": lastName,
        "contact_phone": mobile,
        "password": password,
        "email_address": "$mobile@arjan.app", // ایمیل فیک چون اجباری است
        "device_uiid": "device_01231", // بعداً باید با پکیج device_info واقعی شود
        "device_platform": "android",
        "check_terms_condition": "1",
      },
    );
    
    // در صورت موفقیت، اطلاعات کاربر را برمی‌گرداند
    return UserDto.fromJson(response.data['details']);
  }

  Future<UserDto> _loginAfterReset(String mobile, String password) async {
    final response = await _client.post(
      "/login",
      data: {
        "email_address": mobile,
        "password": password,
        "device_uiid": "device_01231",
        "device_platform": "android"
      },
    );
    return UserDto.fromJson(response.data['details']);
  }
}