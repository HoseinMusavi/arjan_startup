class MerchantDto {
  final String id;
  final String name;
  final String logo;
  final String background;
  final String cuisineText;
  final String distance;
  final double rating;
  final String deliveryFee;
  final String openStatus;

  MerchantDto({
    required this.id,
    required this.name,
    required this.logo,
    required this.background,
    required this.cuisineText,
    required this.distance,
    required this.rating,
    required this.deliveryFee,
    required this.openStatus,
  });

  factory MerchantDto.fromJson(Map<String, dynamic> json) {
    // گرفتن امتیاز با امنیت بالا
    double ratingVal = 0.0;
    if (json['rating'] is Map) {
      ratingVal = double.tryParse(json['rating']['ratings']?.toString() ?? '0') ?? 0.0;
    }

    // مرتب‌سازی قیمت ارسال
    String dFee = json['delivery_charges']?.toString() ?? '0';
    if (dFee.endsWith('.00000')) dFee = dFee.replaceAll('.00000', '');

    return MerchantDto(
      id: json['merchant_id']?.toString() ?? '',
      name: json['restaurant_name']?.toString() ?? 'بدون نام',
      logo: json['logo']?.toString() ?? '',
      background: json['background_url']?.toString() ?? '',
      cuisineText: json['cuisine']?.toString() ?? '',
      distance: json['distance_plot']?.toString() ?? '',
      rating: ratingVal,
      deliveryFee: dFee,
      openStatus: json['open_status']?.toString() ?? '',
    );
  }
}