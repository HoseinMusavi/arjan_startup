import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../models/profile_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileDto> getProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _client;
  final SharedPreferences _prefs;

  ProfileRemoteDataSourceImpl(this._client, this._prefs);

  @override
  Future<ProfileDto> getProfile() async {
    final String userToken = _prefs.getString('client_token') ?? "";
    debugPrint("👤 Profile API Call...");

    try {
      final response = await _client.get("/getProfile", queryParameters: {
        "user_token": userToken,
        "device_platform": "android",
        "lang": "ir",
      });

      if (response.data['code'] == 1) {
        debugPrint("✅ Profile Loaded: ${response.data['details']?['data']?['first_name']}");
        return ProfileDto.fromJson(response.data);
      } else {
        throw Exception(response.data['msg'] ?? "خطا در دریافت پروفایل");
      }
    } catch (e) {
      debugPrint("❌ Profile Error: $e");
      rethrow;
    }
  }
}