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
      // تبدیل جیسون خام به مدل دارت
      return SettingsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}