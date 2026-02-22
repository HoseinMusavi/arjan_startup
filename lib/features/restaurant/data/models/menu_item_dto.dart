class MenuItemDto {
  final String id;
  final String name;
  final String description;
  final String photo;
  final String price;

  MenuItemDto({
    required this.id,
    required this.name,
    required this.description,
    required this.photo,
    required this.price,
  });

  factory MenuItemDto.fromJson(Map<String, dynamic> json) {
    // ۱. استخراج قیمت و پاکسازی فاصله‌های HTML (مثل &nbsp;)
    String finalPrice = 'نامشخص';
    if (json['prices'] != null && json['prices'] is List && json['prices'].isNotEmpty) {
      finalPrice = json['prices'][0].toString();
      // تبدیل فاصله نشکن HTML به فاصله معمولی
      finalPrice = finalPrice.replaceAll('&nbsp;', ' ').trim(); 
    }

    // ۲. استخراج توضیحات غذا
    String rawDescription = json['item_description']?.toString() ?? '';
    
    // ۳. جادوی اصلی: پاکسازی کامل تگ‌های HTML با استفاده از Regular Expression
    // این کد هر چیزی که بین < و > باشد (مثل استایل‌ها و کلاس‌ها) را حذف می‌کند
    String cleanDescription = rawDescription.replaceAll(RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false), ' ');
    
    // پاکسازی کاراکترهای خاص HTML که به صورت متن درآمده‌اند
    cleanDescription = cleanDescription.replaceAll('&nbsp;', ' ');
    cleanDescription = cleanDescription.replaceAll('&zwnj;', ' '); // نیم‌فاصله
    cleanDescription = cleanDescription.replaceAll('&amp;', '&');
    
    // در نهایت حذف فاصله‌های خالی اضافی که ممکنه ایجاد شده باشه
    cleanDescription = cleanDescription.trim();
    // جلوگیری از فاصله‌های چندگانه وسط متن
    cleanDescription = cleanDescription.replaceAll(RegExp(r'\s+'), ' ');

    return MenuItemDto(
      id: json['item_id']?.toString() ?? '',
      name: json['item_name']?.toString() ?? 'بدون نام',
      description: cleanDescription, // متن کاملاً تمیز و خالص فرستاده می‌شود
      photo: json['photo']?.toString() ?? '',
      price: finalPrice, // قیمت تمیز شده
    );
  }
}