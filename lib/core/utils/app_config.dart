import '../../features/splash/data/models/settings_dto.dart';

class AppConfig {
  // Singleton Pattern
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  Map<String, String> _translations = {};
  AppSettingsDto? _settings;
  List<CuisineDto> cuisines = [];

  // متدی برای مقداردهی اولیه بعد از دریافت پاسخ سرور
  void initialize(SettingsResponse data) {
    _translations = data.translationDict;
    _settings = data.appSettings;
    cuisines = data.cuisines;
  }

  // متد ترجمه
  String t(String key) {
    return _translations[key] ?? key;
  }

  // فرمت کردن قیمت
  String formatPrice(double price) {
    if (_settings == null) return price.toString();
    
    // اینجا بعدا لاجیک فرمت دقیق عدد (سه رقم سه رقم) را اضافه می‌کنیم
    // فعلا ساده برمی‌گردانیم
    String formatted = price.toStringAsFixed(2)
        .replaceAll('.', _settings!.priceDecimalSeparator);
        
    if (_settings!.currencyPosition == 'right') {
      return '$formatted ${_settings!.currencySymbol}';
    } else {
      return '${_settings!.currencySymbol} $formatted';
    }
  }
}