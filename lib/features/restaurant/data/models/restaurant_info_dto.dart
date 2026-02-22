class RestaurantInfoDto {
  final String id;
  final String name;
  final String logo;
  final String backgroundUrl;
  final String cuisine;
  final String address;
  final String status;
  final double rating;

  RestaurantInfoDto({
    required this.id, 
    required this.name, 
    required this.logo, 
    required this.backgroundUrl, 
    required this.cuisine, 
    required this.address, 
    required this.status, 
    required this.rating
  });

  factory RestaurantInfoDto.fromJson(Map<String, dynamic> json) {
    // پاکسازی احتمالی کاراکترهای HTML از آدرس
    String rawAddress = json['complete_address']?.toString() ?? '';
    String cleanAddress = rawAddress.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').trim();

    return RestaurantInfoDto(
      id: json['merchant_id']?.toString() ?? '',
      name: json['restaurant_name']?.toString() ?? 'بدون نام',
      logo: json['logo']?.toString() ?? '',
      backgroundUrl: json['background_url']?.toString() ?? '',
      cuisine: json['cuisine']?.toString() ?? '',
      address: cleanAddress,
      status: json['status']?.toString() ?? '',
      rating: double.tryParse(json['rating']?['ratings']?.toString() ?? '0') ?? 0.0,
    );
  }
}