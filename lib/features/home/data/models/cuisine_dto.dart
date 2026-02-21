class CuisineDto {
  final String id;
  final String name;
  final String image;
  final String totalMerchant;

  CuisineDto({
    required this.id,
    required this.name,
    required this.image,
    required this.totalMerchant,
  });

  factory CuisineDto.fromJson(Map<String, dynamic> json) {
    return CuisineDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'بدون نام',
      image: json['featured_image']?.toString() ?? 'https://arjanapp.ir/protected/modules/mobileappv2/assets/images/default_bg.jpg',
      totalMerchant: json['total_merchant']?.toString() ?? '',
    );
  }
}