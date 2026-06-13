import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SessionService {
  final SharedPreferences _prefs;

  SessionService(this._prefs);

  String get userToken {
    // اولویت با client_token (برای سازگاری با AuthRepositoryImpl)
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
    const fallback = 'uiid_01234561';
    return _prefs.getString('device_uiid') ?? fallback;
  }

  Future<void> setUserToken(String token) async {
    // در هر دو کلید ذخیره کن تا همه جا کار کند
    await _prefs.setString('user_token', token);
    await _prefs.setString('client_token', token);
    debugPrint('🔑 [Session] user_token ذخیره شد: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
  }

  Future<void> initDeviceId() async {
    if (!_prefs.containsKey('device_id')) {
      final random = Random();
      final newId = 'device_${random.nextInt(100000)}';
      await _prefs.setString('device_id', newId);
      await _prefs.setString('device_uiid', 'uiid_${random.nextInt(100000)}');
      debugPrint('📱 [Session] device_id ساخته شد: $newId');
    }
  }
}