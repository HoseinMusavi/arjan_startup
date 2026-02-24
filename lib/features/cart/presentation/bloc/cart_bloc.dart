import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arjan_startup/features/cart/domain/repositories/cart_repository.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_item_dto.dart';
import 'cart_event.dart';
import 'cart_state.dart';

export 'cart_event.dart';
export 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repository;
  String _activeMerchantId = ''; 

  CartBloc(this._repository) : super(const CartState()) {
    on<LoadCartCount>(_onLoadCartCount);
    on<AddItemToCart>(_onAddItemToCart);
    on<ClearCartAndAddItem>(_onClearCartAndAddItem);
    on<LoadCartDetails>(_onLoadCartDetails);
  }

  Future<void> _onLoadCartCount(LoadCartCount event, Emitter<CartState> emit) async {
    String targetMerchant = event.merchantId.isNotEmpty ? event.merchantId : _activeMerchantId;
    if (targetMerchant.isEmpty) {
       emit(state.copyWith(status: CartStatus.success, cartCount: 0, basketTotal: '0 تومان'));
       return;
    }

    emit(state.copyWith(status: CartStatus.loading));
    final result = await _repository.getCartCount(targetMerchant, event.lat, event.lng);
    
    result.fold(
      (failure) => emit(state.copyWith(status: CartStatus.failure, errorMessage: failure.message)),
      (data) {
        if (data.count > 0) _activeMerchantId = targetMerchant;
        else if (targetMerchant == _activeMerchantId && data.count == 0) _activeMerchantId = '';
        
        emit(state.copyWith(status: CartStatus.success, cartCount: data.count, basketTotal: data.basketTotal));
      },
    );
  }

  Future<void> _onAddItemToCart(AddItemToCart event, Emitter<CartState> emit) async {
    if (_activeMerchantId.isNotEmpty && _activeMerchantId != event.merchantId) {
      emit(state.copyWith(status: CartStatus.conflict, pendingItem: event.item, pendingMerchantId: event.merchantId, pendingCategoryId: event.categoryId));
      return;
    }

    emit(state.copyWith(status: CartStatus.updating));
    final payload = _buildPayload(event.merchantId, event.item, event.categoryId, event.lat, event.lng);
    
    final addResult = await _repository.addToCart(payload);
    await addResult.fold(
      (failure) async {
        emit(state.copyWith(status: CartStatus.failure, errorMessage: failure.message));
        add(LoadCartCount(event.merchantId, event.lat, event.lng));
      },
      (data) async {
        _activeMerchantId = event.merchantId; 
        add(LoadCartCount(event.merchantId, event.lat, event.lng));
        if (state.cartDetails != null) add(LoadCartDetails(event.lat, event.lng));
      }
    );
  }

  Future<void> _onClearCartAndAddItem(ClearCartAndAddItem event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.updating));
    await _repository.clearCart(_activeMerchantId); 
    
    final payload = _buildPayload(event.merchantId, event.item, event.categoryId, event.lat, event.lng);
    final addResult = await _repository.addToCart(payload);
    
    await addResult.fold(
      (failure) async => emit(state.copyWith(status: CartStatus.failure, errorMessage: failure.message)),
      (data) async {
        _activeMerchantId = event.merchantId;
        add(LoadCartCount(event.merchantId, event.lat, event.lng));
      }
    );
  }

  Future<void> _onLoadCartDetails(LoadCartDetails event, Emitter<CartState> emit) async {
    if (_activeMerchantId.isEmpty) return;
    
    emit(state.copyWith(status: CartStatus.loading));
    final result = await _repository.getCartDetails(_activeMerchantId, event.lat, event.lng);
    
    result.fold(
      (failure) => emit(state.copyWith(status: CartStatus.failure, errorMessage: failure.message)),
      (data) => emit(state.copyWith(status: CartStatus.success, cartDetails: data)),
    );
  }

  Map<String, dynamic> _buildPayload(String merchantId, MenuItemDto item, String categoryId, double lat, double lng) {
    String priceForServer = item.rawPrice;
    if (priceForServer.isEmpty) {
      // فرمت دستی در صورت خالی بودن rawPrice
      String cleanPrice = item.price.replaceAll(RegExp(r'[^0-9]'), '');
      priceForServer = '0|$cleanPrice'; 
    }
    
    return {
      'merchant_id': merchantId,
      'item_id': item.id,
      'category_id': categoryId,
      'qty': '1',
      'price': priceForServer,
      'lat': lat,
      'lng': lng,
    };
  }
}