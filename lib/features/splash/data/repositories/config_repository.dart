import 'package:flutter/material.dart';

import '../../../../core/network/dio_client.dart';
import '../models/settings_dto.dart';

abstract class ConfigRepository {
  Future<SettingsResponse> getSettings();
}

class ConfigRepositoryImpl implements ConfigRepository {
  final DioClient _dioClient;

  ConfigRepositoryImpl(this._dioClient);

  @override
  Future<SettingsResponse> getSettings() async {
    try {
      final response = await _dioClient.get("/getSettings");
      debugPrint('📡 [ConfigRepo] پاسخ دریافت شد');
      
      // ✅ تبدیل جیسون خام به مدل دارت
      final settingsResponse = SettingsResponse.fromJson(response.data);
      debugPrint('✅ [ConfigRepo] تعداد دسته‌بندی‌ها: ${settingsResponse.cuisines.length}');
      
      return settingsResponse;
    } catch (e) {
      debugPrint('❌ [ConfigRepo] خطا: $e');
      rethrow;
    }
  }
}