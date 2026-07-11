import 'package:equatable/equatable.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_item_dto.dart';
import 'package:arjan_startup/features/cart/data/models/cart_details_dto.dart';

enum CartStatus { initial, loading, success, failure, updating, conflict }

class CartState extends Equatable {
  final CartStatus status;
  final int cartCount;
  final String basketTotal;
  final String errorMessage;
  final MenuItemDto? pendingItem;
  final String? pendingMerchantId;
  final String? pendingCategoryId;
  final CartDetailsDto? cartDetails;

  const CartState({
    this.status = CartStatus.initial,
    this.cartCount = 0,
    this.basketTotal = '0 تومان',
    this.errorMessage = '',
    this.pendingItem,
    this.pendingMerchantId,
    this.pendingCategoryId,
    this.cartDetails,
  });

  CartState copyWith({
    CartStatus? status, int? cartCount, String? basketTotal, String? errorMessage,
    MenuItemDto? pendingItem, String? pendingMerchantId, String? pendingCategoryId,
    CartDetailsDto? cartDetails,
  }) {
    return CartState(
      status: status ?? this.status,
      cartCount: cartCount ?? this.cartCount,
      basketTotal: basketTotal ?? this.basketTotal,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingItem: pendingItem ?? this.pendingItem,
      pendingMerchantId: pendingMerchantId ?? this.pendingMerchantId,
      pendingCategoryId: pendingCategoryId ?? this.pendingCategoryId,
      cartDetails: cartDetails ?? this.cartDetails,
    );
  }

  @override
  List<Object?> get props => [status, cartCount, basketTotal, errorMessage, pendingItem, pendingMerchantId, pendingCategoryId, cartDetails];
}