import '../../../../core/network/dio_client.dart';
import '../models/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<String> sendOtp(String mobile);
  Future<UserDto> verifyOtp(String mobile, String token, String code);
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
    // طبق لاگ شما، توکن داخل details -> forgot_password_token است
    return response.data['details']['forgot_password_token'];
  }

  @override
  Future<UserDto> verifyOtp(String mobile, String token, String code) async {
    // 1. تغییر رمز عبور با کد SMS
    // ما توکن را به عنوان رمز جدید ست میکنیم تا فقط لاگین کنیم
    await _client.get(
      "/changePasswordBySMS",
      queryParameters: {
        "forgot_password_token": token,
        "sms_code": code,
        "new_password": token, 
      },
    );
    
    // 2. اگر مرحله بالا خطا ندهد (Interceptor مدیریت میکند)، حالا لاگین میکنیم
    return _loginAfterReset(mobile, token);
  }

  Future<UserDto> _loginAfterReset(String mobile, String password) async {
    final response = await _client.post(
      "/login",
      data: {
        "email_address": mobile,
        "password": password,
        "device_uiid": "uiid_123456_placeholder", 
        "device_platform": "android"
      },
    );
    // طبق لاگین، اطلاعات کاربر در details است
    return UserDto.fromJson(response.data);
  }
}