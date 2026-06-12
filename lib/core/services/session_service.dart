import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SessionService {
  final SharedPreferences _prefs;

  SessionService(this._prefs);

  // دریافت توکن کاربر (بعد از لاگین ذخیره می‌شود)
  String get userToken {
    return _prefs.getString('user_token') ?? '';
  }

  // دریافت device_id (در صورت نبود، یک مقدار ثابت موقت برمی‌گرداند)
  String get deviceId {
    const fallback = 'device_01231';
    return _prefs.getString('device_id') ?? fallback;
  }

  // دریافت device_uiid (مشابه device_id)
  String get deviceUiid {
    const fallback = 'uiid_01234561';
    return _prefs.getString('device_uiid') ?? fallback;
  }

  // به‌روزرسانی توکن بعد از لاگین
  Future<void> setUserToken(String token) async {
    await _prefs.setString('user_token', token);
  }

  // تولید و ذخیره device_id و device_uiid (در اولین اجرا)
  Future<void> initDeviceId() async {
    if (!_prefs.containsKey('device_id')) {
      final random = Random();
      final newId = 'device_${random.nextInt(100000)}';
      await _prefs.setString('device_id', newId);
      await _prefs.setString('device_uiid', 'uiid_${random.nextInt(100000)}');
    }
  }
}