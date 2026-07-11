class CartCountDto {
  final int count;
  final String basketCount;
  final String basketTotal;

  CartCountDto({
    required this.count,
    required this.basketCount,
    required this.basketTotal,
  });

  factory CartCountDto.fromJson(Map<String, dynamic> json) {
    return CartCountDto(
      count: json['count'] ?? 0,
      basketCount: json['basket_count']?.toString() ?? '0',
      basketTotal: json['basket_total']?.toString() ?? '0 تومان',
    );
  }
}

class AddToCartResponseDto {
  final String message;
  final int cartCount;

  AddToCartResponseDto({
    required this.message,
    required this.cartCount,
  });

  factory AddToCartResponseDto.fromJson(Map<String, dynamic> json) {
    return AddToCartResponseDto(
      message: json['msg']?.toString() ?? '',
      cartCount: json['details']?['cart_count'] ?? 0,
    );
  }
}