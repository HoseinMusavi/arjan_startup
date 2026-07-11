class PromoItemDto {
  final String merchantId;
  final String itemId;
  final String itemName;
  final String photo;
  final String price;
  final String discount;
  final String itemDescription;
  final String restaurantName;
  final List<String> prices;
  final List<Map<String, String>> prices2;

  PromoItemDto({
    required this.merchantId,
    required this.itemId,
    required this.itemName,
    required this.photo,
    required this.price,
    required this.discount,
    required this.itemDescription,
    required this.restaurantName,
    required this.prices,
    required this.prices2,
  });

  factory PromoItemDto.fromJson(Map<String, dynamic> json) {
    return PromoItemDto(
      merchantId: json['merchant_id']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      discount: json['discount']?.toString() ?? '',
      itemDescription: json['item_description']?.toString() ?? '',
      restaurantName: json['restaurant_name']?.toString() ?? '',
      prices: (json['prices'] as List?)?.map((e) => e.toString()).toList() ?? [],
      prices2: (json['prices2'] as List?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
    );
  }

  int get discountedPriceInt {
    try {
      final original = int.tryParse(price.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
      final disc = int.tryParse(discount) ?? 0;
      return original - disc;
    } catch (e) {
      return 0;
    }
  }

  String get discountedPriceFormatted {
    final value = discountedPriceInt;
    return '$value تومان';
  }
}

class PromoResponseDto {
  final int code;
  final String msg;
  final List<PromoItemDto> items;

  PromoResponseDto({
    required this.code,
    required this.msg,
    required this.items,
  });

  factory PromoResponseDto.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>?;
    final List<dynamic> list = details?['list'] ?? [];
    return PromoResponseDto(
      code: json['code'] as int? ?? 0,
      msg: json['msg']?.toString() ?? '',
      items: list.map((e) => PromoItemDto.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  bool get isSuccess => code == 1;
}