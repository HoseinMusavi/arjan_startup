class MenuItemDto {
  final String id;
  final String name;
  final String description;
  final String photo;
  final String price;

  MenuItemDto({required this.id, required this.name, required this.description, required this.photo, required this.price});

  factory MenuItemDto.fromJson(Map<String, dynamic> json) {
    String finalPrice = 'نامشخص';
    if (json['prices'] != null && json['prices'] is List && json['prices'].isNotEmpty) {
      finalPrice = json['prices'][0].toString();
    }
    return MenuItemDto(
      id: json['item_id']?.toString() ?? '',
      name: json['item_name']?.toString() ?? 'بدون نام',
      description: json['item_description']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',
      price: finalPrice,
    );
  }
}