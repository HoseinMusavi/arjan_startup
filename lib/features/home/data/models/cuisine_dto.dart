class CuisineDto {
  final String id;
  final String name;
  final String image;

  CuisineDto({
    required this.id,
    required this.name,
    required this.image,
  });

  factory CuisineDto.fromJson(Map<String, dynamic> json) {
    // اصلاح لینک عکس: اضافه کردن آدرس سایت به ابتدای نام فایل
    final imageName = json['featured_image']?.toString() ?? '';
    final imageUrl = imageName.isNotEmpty && !imageName.startsWith('http')
        ? 'https://arjanapp.ir/upload/$imageName'
        : (imageName.startsWith('http') ? imageName : 'https://arjanapp.ir/protected/modules/mobileappv2/assets/images/default_bg.jpg');

    return CuisineDto(
      id: json['cuisine_id']?.toString() ?? '',
      name: json['cuisine_name']?.toString() ?? 'بدون نام',
      image: imageUrl,
    );
  }
}