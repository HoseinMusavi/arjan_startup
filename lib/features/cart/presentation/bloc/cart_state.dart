import 'package:equatable/equatable.dart';

enum CartStatus { initial, loading, success, failure, updating }

class CartState extends Equatable {
  final CartStatus status;
  final int cartCount;
  final String basketTotal;
  final String errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.cartCount = 0,
    this.basketTotal = '0 تومان',
    this.errorMessage = '',
  });

  CartState copyWith({CartStatus? status, int? cartCount, String? basketTotal, String? errorMessage}) {
    return CartState(
      status: status ?? this.status,
      cartCount: cartCount ?? this.cartCount,
      basketTotal: basketTotal ?? this.basketTotal,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, cartCount, basketTotal, errorMessage];
}