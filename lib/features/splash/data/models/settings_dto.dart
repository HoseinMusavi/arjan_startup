class SettingsResponse {
  final Map<String, String> translationDict;
  final List<CuisineDto> cuisines;
  final AppSettingsDto appSettings;

  SettingsResponse({
    required this.translationDict,
    required this.cuisines,
    required this.appSettings,
  });

  factory SettingsResponse.fromJson(Map<String, dynamic> json) {
    final details = json['details'] ?? {};
    // تغییر مهم: دسترسی به لایه settings درون details
    final settingsJson = details['settings'] ?? {};
    
    // 1. Parse Dictionary (dict) from settings
    Map<String, String> dict = {};
    if (settingsJson['dict'] != null) {
      (settingsJson['dict'] as Map<String, dynamic>).forEach((key, value) {
        if (value is Map && value['ir'] != null) {
          // چک می‌کنیم ترجمه خالی نباشد
          dict[key] = value['ir'].toString().isNotEmpty ? value['ir'] : key;
        } else {
          dict[key] = key;
        }
      });
    }

    // 2. Parse Cuisines from settings
    List<CuisineDto> cuisineList = [];
    if (settingsJson['cuisine'] != null) {
      settingsJson['cuisine'].forEach((v) {
        cuisineList.add(CuisineDto.fromJson(v));
      });
    }

    return SettingsResponse(
      translationDict: dict,
      cuisines: cuisineList,
      appSettings: AppSettingsDto.fromJson(settingsJson),
    );
  }
}

class CuisineDto {
  final String id;
  final String name;
  final String image;

  CuisineDto({required this.id, required this.name, required this.image});

  factory CuisineDto.fromJson(Map<String, dynamic> json) {
    return CuisineDto(
      id: json['cuisine_id'].toString(),
      name: json['cuisine_name'] ?? '',
      image: json['featured_image'] ?? '',
    );
  }
}

class AppSettingsDto {
  final String currencySymbol;
  final String currencyPosition; // 'right' or 'left'
  final String priceDecimalSeparator;
  final String priceThousandSeparator;

  AppSettingsDto({
    required this.currencySymbol,
    required this.currencyPosition,
    required this.priceDecimalSeparator,
    required this.priceThousandSeparator,
  });

  factory AppSettingsDto.fromJson(Map<String, dynamic> json) {
    return AppSettingsDto(
      currencySymbol: json['currency_symbol'] ?? 'تومان',
      currencyPosition: json['currency_position'] ?? 'right',
      priceDecimalSeparator: json['currency_decimal_separator'] ?? '.',
      priceThousandSeparator: json['currency_thousand_separator'] ?? ',',
    );
  }
}