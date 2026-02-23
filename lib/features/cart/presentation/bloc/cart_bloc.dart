import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arjan_startup/features/cart/domain/repositories/cart_repository.dart';

import 'cart_event.dart';
import 'cart_state.dart';

export 'cart_event.dart';
export 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repository;

  CartBloc(this._repository) : super(const CartState()) {
    on<LoadCartCount>(_onLoadCartCount);
    on<AddItemToCart>(_onAddItemToCart);
  }

  Future<void> _onLoadCartCount(LoadCartCount event, Emitter<CartState> emit) async {
    log('🛒 [CartBloc] در حال دریافت اطلاعات سبد خرید...');
    emit(state.copyWith(status: CartStatus.loading));
    
    final result = await _repository.getCartCount(event.merchantId, event.lat, event.lng);
    
    result.fold(
      (failure) {
        log('❌ [CartBloc] خطا در لود سبد خرید: ${failure.message}');
        emit(state.copyWith(status: CartStatus.failure, errorMessage: failure.message));
      },
      (data) {
        log('✅ [CartBloc] تعداد: ${data.count} | مبلغ کل: ${data.basketTotal}');
        emit(state.copyWith(status: CartStatus.success, cartCount: data.count, basketTotal: data.basketTotal));
      },
    );
  }

  Future<void> _onAddItemToCart(AddItemToCart event, Emitter<CartState> emit) async {
    log('🛒 [CartBloc] درخواست افزودن آیتم: ${event.item.name}');
    emit(state.copyWith(status: CartStatus.updating));

    final payload = {
      'merchant_id': event.merchantId,
      'item_id': event.item.id,
      'category_id': event.categoryId,
      'qty': 1,
      'lat': event.lat,
      'lng': event.lng,
    };

    final addResult = await _repository.addToCart(payload);
    
    await addResult.fold(
      (failure) async {
        log('❌ [CartBloc] خطا: ${failure.message}');
        emit(state.copyWith(status: CartStatus.failure, errorMessage: failure.message));
        add(LoadCartCount(event.merchantId, event.lat, event.lng));
      },
      (data) async {
        log('✅ [CartBloc] اضافه شد!');
        add(LoadCartCount(event.merchantId, event.lat, event.lng));
      }
    );
  }
}