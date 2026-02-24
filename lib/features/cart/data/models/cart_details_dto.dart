class CartDetailsDto {
  final String merchantName;
  final String merchantLogo;
  final List<CartItemDto> items;
  final double subtotal;
  final double deliveryCharges;
  final double total;
  final int availablePoints;

  CartDetailsDto({
    required this.merchantName,
    required this.merchantLogo,
    required this.items,
    required this.subtotal,
    required this.deliveryCharges,
    required this.total,
    required this.availablePoints,
  });

  factory CartDetailsDto.fromJson(Map<String, dynamic> json) {
    var merchant = json['merchant'] ?? {};
    var data = json['data'] ?? {};
    var totalData = json['total'] ?? {};
    
    List<CartItemDto> parsedItems = [];
    if (data['item'] != null && data['item'] is List) {
      parsedItems = (data['item'] as List).map((i) => CartItemDto.fromJson(i)).toList();
    }

    return CartDetailsDto(
      merchantName: merchant['restaurant_name']?.toString() ?? 'فروشگاه',
      merchantLogo: merchant['background_url']?.toString() ?? '',
      items: parsedItems,
      subtotal: double.tryParse(totalData['subtotal']?.toString() ?? '0') ?? 0,
      deliveryCharges: double.tryParse(totalData['delivery_charges']?.toString() ?? '0') ?? 0,
      total: double.tryParse(totalData['total']?.toString() ?? '0') ?? 0,
      availablePoints: int.tryParse(json['available_points']?.toString() ?? '0') ?? 0,
    );
  }
}

class CartItemDto {
  final String itemId;
  final String itemName;
  final int qty;
  final double price;
  final String categoryId;

  CartItemDto({
    required this.itemId,
    required this.itemName,
    required this.qty,
    required this.price,
    required this.categoryId,
  });

  factory CartItemDto.fromJson(Map<String, dynamic> json) {
    return CartItemDto(
      itemId: json['item_id']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? 'آیتم نامشخص',
      qty: int.tryParse(json['qty']?.toString() ?? '1') ?? 1,
      price: double.tryParse(json['discounted_price']?.toString() ?? json['normal_price']?.toString() ?? '0') ?? 0,
      categoryId: json['category_id']?.toString() ?? '',
    );
  }
}