import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SessionService {
  final SharedPreferences _prefs;

  SessionService(this._prefs);

  String get userToken {
    var token = _prefs.getString('client_token') ?? '';
    if (token.isEmpty) {
      token = _prefs.getString('user_token') ?? '';
    }
    debugPrint('🔑 [Session] user_token: ${token.isNotEmpty ? token.substring(0, token.length > 10 ? 10 : token.length) : '(empty)'}...');
    return token;
  }

  String get deviceId {
    const fallback = 'device_01231';
    return _prefs.getString('device_id') ?? fallback;
  }

  String get deviceUiid {
    // ✅ اگر کاربر لاگین است، device_uiid رو بر اساس user_token تولید کن
    final token = userToken;
    if (token.isNotEmpty && token != 'null') {
      // تولید device_uiid یکتا بر اساس توکن کاربر
      final uniqueId = 'uiid_${token.substring(0, token.length > 8 ? 8 : token.length)}';
      debugPrint('📱 [Session] device_uiid بر اساس توکن: $uniqueId');
      return uniqueId;
    }
    
    // اگر کاربر لاگین نیست، از device_uiid ذخیره شده استفاده کن
    const fallback = 'uiid_01234561';
    final saved = _prefs.getString('device_uiid') ?? fallback;
    debugPrint('📱 [Session] device_uiid از حافظه: $saved');
    return saved;
  }

  Future<void> setUserToken(String token) async {
    await _prefs.setString('user_token', token);
    await _prefs.setString('client_token', token);
    
    // ✅ بعد از ذخیره توکن، device_uiid رو هم بروزرسانی کن
    final uniqueId = 'uiid_${token.substring(0, token.length > 8 ? 8 : token.length)}';
    await _prefs.setString('device_uiid', uniqueId);
    
    debugPrint('🔑 [Session] user_token ذخیره شد: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
    debugPrint('📱 [Session] device_uiid بروزرسانی شد: $uniqueId');
  }

  Future<void> initDeviceId() async {
    if (!_prefs.containsKey('device_id')) {
      final random = Random();
      final newId = 'device_${random.nextInt(100000)}';
      await _prefs.setString('device_id', newId);
      
      // فقط در صورتی device_uiid رو بساز که توکنی وجود نداشته باشد
      final token = userToken;
      if (token.isEmpty || token == 'null') {
        final uiid = 'uiid_${random.nextInt(100000)}';
        await _prefs.setString('device_uiid', uiid);
        debugPrint('📱 [Session] device_uiid ساخته شد: $uiid');
      }
      
      debugPrint('📱 [Session] device_id ساخته شد: $newId');
    }
  }
  
  // ✅ متد جدید برای خروج از حساب
  Future<void> clearSession() async {
    await _prefs.remove('client_token');
    await _prefs.remove('user_token');
    // device_uiid رو پاک نکنید چون مهمه
    debugPrint('🗑️ [Session] توکن‌ها پاک شدند');
  }
}