import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arjan_startup/features/cart/domain/repositories/cart_repository.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_item_dto.dart';
import 'package:arjan_startup/features/restaurant/domain/repositories/restaurant_repository.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
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
    on<RemoveItemFromCart>(_onRemoveItemFromCart);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
  }

  Future<void> _onLoadCartCount(LoadCartCount event, Emitter<CartState> emit) async {
    String targetMerchant = event.merchantId.isNotEmpty ? event.merchantId : _activeMerchantId;
    if (targetMerchant.isEmpty) {
       emit(state.copyWith(status: CartStatus.success, cartCount: 0, basketTotal: '0 تومان'));
       return;
    }

    final result = await _repository.getCartCount(targetMerchant, event.lat, event.lng);
    
    result.fold(
      (failure) => emit(state.copyWith(status: CartStatus.success, cartCount: 0, basketTotal: '0 تومان')),
      (data) {
        if (data.count > 0) _activeMerchantId = targetMerchant;
        else if (targetMerchant == _activeMerchantId && data.count == 0) _activeMerchantId = '';
        
        emit(state.copyWith(status: CartStatus.success, cartCount: data.count, basketTotal: data.basketTotal));
      },
    );
  }

  // تابع بررسی وضعیت فروشگاه
 Future<bool> _isMerchantActive(String merchantId, double lat, double lng) async {
  try {
    final restaurantRepo = getIt<RestaurantRepository>();
    final result = await restaurantRepo.getRestaurantInfo(merchantId, lat, lng);
    
    return result.fold(
      (failure) => false,
      (info) {
        // بررسی وضعیت فروشگاه
        final isOpen = info.status == 'باز است' || 
                       info.status == 'open' || 
                       info.status == 'Open';
        
        // لاگ برای دیباگ
        print('🔍 فروشگاه ${info.name}: status=${info.status}, isOpen=$isOpen');
        
        return isOpen;
      },
    );
  } catch (e) {
    return false;
  }
}

  Future<void> _onAddItemToCart(AddItemToCart event, Emitter<CartState> emit) async {
  // بررسی فعال بودن فروشگاه
  final isActive = await _isMerchantActive(event.merchantId, event.lat, event.lng);
  
  if (!isActive) {
    emit(state.copyWith(
      status: CartStatus.failure, 
      errorMessage: 'این فروشگاه در حال حاضر غیرفعال است و امکان ثبت سفارش وجود ندارد.'
    ));
    return;
  }

  // اگه سبد خالیه یا همون فروشگاهه، اجازه بده
  if (_activeMerchantId.isNotEmpty && _activeMerchantId != event.merchantId) {
    emit(state.copyWith(
      status: CartStatus.conflict, 
      pendingItem: event.item, 
      pendingMerchantId: event.merchantId, 
      pendingCategoryId: event.categoryId
    ));
    return;
  }

  emit(state.copyWith(status: CartStatus.updating));
  final payload = _buildPayload(event.merchantId, event.item, event.categoryId, event.lat, event.lng);
  
  final addResult = await _repository.addToCart(payload);
  await addResult.fold(
    (failure) async {
      emit(state.copyWith(status: CartStatus.failure, errorMessage: failure.message));
    },
    (data) async {
      _activeMerchantId = event.merchantId; 
      // ✅ فقط تعداد رو بروز کن، جزییات رو بعداً خودکار میاد
      add(LoadCartCount(event.merchantId, event.lat, event.lng));
      // ❌ این خط رو حذف کن یا شرط بذار
      // add(LoadCartDetails(event.lat, event.lng));
    }
  );
}

  Future<void> _onClearCartAndAddItem(ClearCartAndAddItem event, Emitter<CartState> emit) async {
  // بررسی فعال بودن فروشگاه
  final isActive = await _isMerchantActive(event.merchantId, event.lat, event.lng);
  
  if (!isActive) {
    emit(state.copyWith(
      status: CartStatus.failure, 
      errorMessage: 'این فروشگاه در حال حاضر غیرفعال است و امکان ثبت سفارش وجود ندارد.'
    ));
    return;
  }

  emit(state.copyWith(status: CartStatus.updating));
  await _repository.clearCart(_activeMerchantId); 
  
  final payload = _buildPayload(event.merchantId, event.item, event.categoryId, event.lat, event.lng);
  final addResult = await _repository.addToCart(payload);
  
  await addResult.fold(
    (failure) async => emit(state.copyWith(status: CartStatus.failure, errorMessage: failure.message)),
    (data) async {
      _activeMerchantId = event.merchantId;
      add(LoadCartCount(event.merchantId, event.lat, event.lng));
      // ❌ این خط رو هم حذف کن
      // add(LoadCartDetails(event.lat, event.lng));
    }
  );
}

  Future<void> _onLoadCartDetails(LoadCartDetails event, Emitter<CartState> emit) async {
  if (_activeMerchantId.isEmpty) {
    // اگه سبد فعالی نیست، state رو تغییر نده
    return;
  }
  
  final result = await _repository.getCartDetails(_activeMerchantId, event.lat, event.lng);
  
  result.fold(
    (failure) {
      // خطا رو نادیده بگیر و state قبلی رو حفظ کن
      // emit(state.copyWith(status: CartStatus.success, cartDetails: null));
    },
    (data) {
      if (data.items.isNotEmpty) {
        emit(state.copyWith(status: CartStatus.success, cartDetails: data));
      }
      // اگه خالی بود، تغییری نده
    },
  );
}

  Future<void> _onRemoveItemFromCart(RemoveItemFromCart event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.updating));
    add(LoadCartCount(_activeMerchantId, event.lat, event.lng));
    add(LoadCartDetails(event.lat, event.lng));
  }

  Future<void> _onUpdateItemQuantity(UpdateItemQuantity event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.updating));
    add(LoadCartCount(_activeMerchantId, event.lat, event.lng));
    add(LoadCartDetails(event.lat, event.lng));
  }

  Map<String, dynamic> _buildPayload(String merchantId, MenuItemDto item, String categoryId, double lat, double lng) {
    String priceForServer = item.rawPrice;
    if (priceForServer.isEmpty) {
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