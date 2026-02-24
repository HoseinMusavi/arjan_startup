class MenuItemDto {
  final String id;
  final String name;
  final String description;
  final String photo;
  final String price;
  final String rawPrice;

  MenuItemDto({
    required this.id,
    required this.name,
    required this.description,
    required this.photo,
    required this.price,
    required this.rawPrice,
  });

  factory MenuItemDto.fromJson(Map<String, dynamic> json) {
    String finalPrice = 'نامشخص';
    if (json['prices'] != null && json['prices'] is List && (json['prices'] as List).isNotEmpty) {
      finalPrice = json['prices'][0].toString().replaceAll('&nbsp;', ' ').trim();
      finalPrice = finalPrice.replaceAll(RegExp(r'<[^>]*>'), '');
    }

    String rawDescription = json['item_description']?.toString() ?? '';
    String cleanDescription = rawDescription.replaceAll(RegExp(r'</p>|<br\s*/?>', caseSensitive: false), '\n');
    cleanDescription = cleanDescription.replaceAll(RegExp(r'<[^>]*>'), '');
    cleanDescription = cleanDescription.replaceAll('&nbsp;', ' ').replaceAll('&amp;', '&').replaceAll('&quot;', '"').replaceAll('&lt;', '<').replaceAll('&gt;', '>');
    cleanDescription = cleanDescription.replaceAll(RegExp(r'\n+'), '\n').trim();

    // ✅ پردازش هوشمندانه قیمت خام برای ارسال به سرور
    String priceForServer = '';
    try {
      if (json['price'] != null) {
        String pStr = json['price'].toString();
        // پاک کردن کاراکترهای اضافی آرایه و آبجکت
        pStr = pStr.replaceAll('{', '').replaceAll('}', '').replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').replaceAll("'", '');
        if (pStr.contains(':')) {
           var p = pStr.split(':');
           priceForServer = '${p[0].trim()}|${p[1].trim()}'; 
        } else {
           priceForServer = pStr.trim(); 
        }
      }
    } catch(e) {}

    return MenuItemDto(
      id: json['item_id']?.toString() ?? '',
      name: json['item_name']?.toString() ?? 'بدون نام',
      description: cleanDescription,
      photo: json['photo']?.toString() ?? '',
      price: finalPrice,
      rawPrice: priceForServer, // ✅ ذخیره قیمت خام با فرمت مورد تایید بک‌اند
    );
  }
}