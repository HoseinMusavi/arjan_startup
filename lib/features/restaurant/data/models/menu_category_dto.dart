class MenuCategoryDto {
  final String id;
  final String name;

  MenuCategoryDto({required this.id, required this.name});

  factory MenuCategoryDto.fromJson(Map<String, dynamic> json) {
    return MenuCategoryDto(
      id: json['cat_id']?.toString() ?? '',
      name: json['category_name']?.toString() ?? 'بدون نام',
    );
  }
}