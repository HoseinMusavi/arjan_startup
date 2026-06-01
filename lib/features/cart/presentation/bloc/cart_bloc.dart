import 'package:arjan_startup/features/cart/data/models/address_model.dart';
import 'package:arjan_startup/features/cart/data/models/delivery_time_model.dart';
import 'package:arjan_startup/features/cart/data/models/payment_method_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:arjan_startup/core/error/failures.dart';
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
    on<LoadFirstCart>(_onLoadFirstCart);
  }

  Future<void> _onLoadFirstCart(LoadFirstCart event, Emitter<CartState> emit) async {
    print('🛒 [CART_BLOC] دریافت اولین سبد خرید');
    emit(state.copyWith(status: CartStatus.loading));
    
    final result = await _repository.getFirstCart(event.lat, event.lng);
    
    result.fold(
      (failure) {
        print('❌ [CART_BLOC] خطا در دریافت اولین سبد خرید: ${failure.message}');
        emit(state.copyWith(status: CartStatus.success));
      },
      (data) {
        if (data.items.isNotEmpty) {
          print('✅ [CART_BLOC] اولین سبد خرید دریافت شد: ${data.items.length} آیتم');
          _activeMerchantId = data.merchantName;
          emit(state.copyWith(
            status: CartStatus.success, 
            cartDetails: data,
            cartCount: data.items.length,
            basketTotal: '${data.total.toStringAsFixed(0)} تومان',
          ));
        } else {
          print('📭 [CART_BLOC] اولین سبد خرید خالی است');
          emit(state.copyWith(status: CartStatus.success));
        }
      },
    );
  }

  Future<void> _onLoadCartCount(LoadCartCount event, Emitter<CartState> emit) async {
    String targetMerchant = event.merchantId.isNotEmpty ? event.merchantId : _activeMerchantId;
    
    // اگر merchantId خالی است و _activeMerchantId هم خالی، فقط ریست کن
    if (targetMerchant.isEmpty) {
      _activeMerchantId = '';
      emit(state.copyWith(status: CartStatus.success, cartCount: 0, basketTotal: '0 تومان', cartDetails: null));
      return;
    }

    print('🛒 [CART_BLOC] دریافت تعداد سبد خرید برای فروشگاه: $targetMerchant');
    
    final result = await _repository.getCartCount(targetMerchant, event.lat, event.lng);
    
    result.fold(
      (failure) => emit(state.copyWith(status: CartStatus.success, cartCount: 0, basketTotal: '0 تومان')),
      (data) {
        if (data.count > 0) {
          _activeMerchantId = targetMerchant;
        } else if (targetMerchant == _activeMerchantId && data.count == 0) {
          _activeMerchantId = '';
        }
        
        print('✅ [CART_BLOC] تعداد سبد خرید: ${data.count}, مجموع: ${data.basketTotal}');
        emit(state.copyWith(status: CartStatus.success, cartCount: data.count, basketTotal: data.basketTotal));
      },
    );
  }

  Future<bool> _isMerchantActive(String merchantId, double lat, double lng) async {
    try {
      final restaurantRepo = getIt<RestaurantRepository>();
      final result = await restaurantRepo.getRestaurantInfo(merchantId, lat, lng);
      
      return result.fold(
        (failure) => false,
        (info) {
          final isOpen = info.status == 'باز است' || info.status == 'open' || info.status == 'Open';
          print('🔍 [CART_BLOC] فروشگاه ${info.name}: status=${info.status}, isOpen=$isOpen');
          return isOpen;
        },
      );
    } catch (e) {
      print('❌ [CART_BLOC] خطا در بررسی وضعیت فروشگاه: $e');
      return false;
    }
  }

  Future<void> _onAddItemToCart(AddItemToCart event, Emitter<CartState> emit) async {
    print('🛒 [CART_BLOC] _onAddItemToCart شروع شد');
    print('   📦 merchantId: ${event.merchantId}');
    print('   🍔 itemId: ${event.item.id}, name: ${event.item.name}');
    print('   📍 lat: ${event.lat}, lng: ${event.lng}');
    
    final isActive = await _isMerchantActive(event.merchantId, event.lat, event.lng);
    print('🔍 [CART_BLOC] نتیجه بررسی فروشگاه: isActive=$isActive');
    
    if (!isActive) {
      print('❌ [CART_BLOC] فروشگاه غیرفعال است، ارسال خطا');
      emit(state.copyWith(
        status: CartStatus.failure, 
        errorMessage: 'این فروشگاه در حال حاضر غیرفعال است و امکان ثبت سفارش وجود ندارد.'
      ));
      return;
    }

    if (_activeMerchantId.isNotEmpty && _activeMerchantId != event.merchantId) {
      print('⚠️ [CART_BLOC] تداخل فروشگاه: فعال=${_activeMerchantId}, جدید=${event.merchantId}');
      emit(state.copyWith(
        status: CartStatus.conflict, 
        pendingItem: event.item, 
        pendingMerchantId: event.merchantId, 
        pendingCategoryId: event.categoryId
      ));
      return;
    }

    emit(state.copyWith(status: CartStatus.updating));
    print('🔄 [CART_BLOC] در حال افزودن به سبد...');
    
    final payload = _buildPayload(event.merchantId, event.item, event.categoryId, event.lat, event.lng);
    print('📦 [CART_BLOC] payload ساخته شد: $payload');
    
    final addResult = await _repository.addToCart(payload);
    await addResult.fold(
      (failure) async {
        print('❌ [CART_BLOC] خطا در افزودن: ${failure.message}');
        emit(state.copyWith(status: CartStatus.failure, errorMessage: failure.message));
      },
      (data) async {
        print('✅ [CART_BLOC] افزودن موفق بود، cartCount: ${data.cartCount}');
        _activeMerchantId = event.merchantId; 
        add(LoadCartCount(event.merchantId, event.lat, event.lng));
      }
    );
  }

  Future<void> _onClearCartAndAddItem(ClearCartAndAddItem event, Emitter<CartState> emit) async {
    print('🔄 [CART_BLOC] پاک کردن سبد و افزودن آیتم جدید');
    
    final isActive = await _isMerchantActive(event.merchantId, event.lat, event.lng);
    
    if (!isActive) {
      print('❌ [CART_BLOC] فروشگاه غیرفعال است، ارسال خطا');
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
        print('✅ [CART_BLOC] سبد پاک و آیتم جدید اضافه شد');
        _activeMerchantId = event.merchantId;
        add(LoadCartCount(event.merchantId, event.lat, event.lng));
      }
    );
  }

  Future<void> _onLoadCartDetails(LoadCartDetails event, Emitter<CartState> emit) async {
    if (_activeMerchantId.isEmpty) {
      print('⚠️ [CART_BLOC] هیچ فروشگاه فعالی برای دریافت جزئیات وجود ندارد');
      emit(state.copyWith(status: CartStatus.success, cartDetails: null));
      return;
    }
    
    print('🛒 [CART_BLOC] دریافت جزئیات سبد خرید برای فروشگاه: $_activeMerchantId');
    final result = await _repository.getCartDetails(_activeMerchantId, event.lat, event.lng);
    
    result.fold(
      (failure) {
        print('❌ [CART_BLOC] خطا در دریافت جزئیات: ${failure.message}');
      },
      (data) {
        if (data.items.isNotEmpty) {
          print('✅ [CART_BLOC] جزئیات سبد خرید دریافت شد: ${data.items.length} آیتم');
          emit(state.copyWith(status: CartStatus.success, cartDetails: data));
        } else {
          print('📭 [CART_BLOC] سبد خرید خالی است');
          emit(state.copyWith(status: CartStatus.success, cartDetails: null));
        }
      },
    );
  }

  Future<void> _onRemoveItemFromCart(RemoveItemFromCart event, Emitter<CartState> emit) async {
    print('🛒 [CART_BLOC] حذف آیتم ${event.itemId} از سبد خرید');
    emit(state.copyWith(status: CartStatus.updating));
    add(LoadCartCount(_activeMerchantId, event.lat, event.lng));
    add(LoadCartDetails(event.lat, event.lng));
  }

  Future<void> _onUpdateItemQuantity(UpdateItemQuantity event, Emitter<CartState> emit) async {
    print('🛒 [CART_BLOC] آپدیت تعداد آیتم ${event.itemId} به ${event.quantity}');
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

  /// دریافت شناسه فروشگاه فعال
  String getActiveMerchantId() => _activeMerchantId;

  /// خالی کردن کامل سبد خرید فروشگاه فعال
  Future<Either<Failure, void>> clearCart(String merchantId, double lat, double lng) async {
    print('🗑️ [CART_BLOC] درخواست خالی کردن سبد خرید برای فروشگاه: $merchantId');
    try {
      final result = await _repository.clearCart(merchantId);
      print('✅ [CART_BLOC] سبد خرید با موفقیت خالی شد');
      
      // ریست کردن merchantId فعال
      _activeMerchantId = '';
      
      // بروزرسانی وضعیت
      add(LoadCartCount('', lat, lng));
      add(LoadCartDetails(lat, lng));
      
      return result;
    } catch (e) {
      print('❌ [CART_BLOC] خطا در خالی کردن سبد: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  // ==================== متدهای جدید برای صفحه آدرس و پرداخت ====================

  Future<Either<Failure, List<AddressDto>>> getAddressBookDropDown() async {
    print('📦 [CART_BLOC] دریافت لیست آدرس‌های کاربر');
    try {
      final result = await _repository.getAddressBookDropDown();
      print('✅ [CART_BLOC] تعداد آدرس‌های دریافت شده: ${result.fold((l) => 0, (r) => r.length)}');
      return result;
    } catch (e) {
      print('❌ [CART_BLOC] خطا در دریافت آدرس‌ها: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, AddressResponseDto>> setDeliveryAddress({
    required double lat,
    required double lng,
    required String street,
    required String city,
    required String state,
    required String zipcode,
    required String countryCode,
    required String locationName,
    required String contactPhone,
    required String merchantId,
  }) async {
    print('📦 [CART_BLOC] ثبت آدرس جدید: $locationName - $street');
    try {
      final result = await _repository.setDeliveryAddress(
        lat: lat,
        lng: lng,
        street: street,
        city: city,
        state: state,
        zipcode: zipcode,
        countryCode: countryCode,
        locationName: locationName,
        contactPhone: contactPhone,
        merchantId: merchantId,
      );
      print('✅ [CART_BLOC] آدرس با موفقیت ثبت شد');
      return result;
    } catch (e) {
      print('❌ [CART_BLOC] خطا در ثبت آدرس: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Map<String, String>>> getDeliveryDateList(String merchantId) async {
    print('📦 [CART_BLOC] دریافت تاریخ‌های تحویل برای فروشگاه: $merchantId');
    try {
      final result = await _repository.getDeliveryDateList(merchantId);
      print('✅ [CART_BLOC] تعداد تاریخ‌های دریافت شده: ${result.fold((l) => 0, (r) => r.length)}');
      return result;
    } catch (e) {
      print('❌ [CART_BLOC] خطا در دریافت تاریخ‌ها: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Map<String, String>>> getDeliveryTimeList(String merchantId, String deliveryDate) async {
    print('📦 [CART_BLOC] دریافت ساعات تحویل برای تاریخ: $deliveryDate');
    try {
      final result = await _repository.getDeliveryTimeList(merchantId, deliveryDate);
      print('✅ [CART_BLOC] تعداد ساعات دریافت شده: ${result.fold((l) => 0, (r) => r.length)}');
      return result;
    } catch (e) {
      print('❌ [CART_BLOC] خطا در دریافت ساعات: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, RedeemPointsResponseDto>> applyRedeemPoints(int points, String merchantId) async {
    print('📦 [CART_BLOC] اعمال امتیاز: $points امتیاز');
    try {
      final result = await _repository.applyRedeemPoints(points, merchantId);
      print('✅ [CART_BLOC] نتیجه اعمال امتیاز: ${result.fold((l) => "خطا", (r) => r.success ? "موفق" : r.message)}');
      return result;
    } catch (e) {
      print('❌ [CART_BLOC] خطا در اعمال امتیاز: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, PreCheckoutResponseDto>> preCheckout({
    required String transactionType,
    required String deliveryDate,
    required String deliveryTime,
    required String merchantId,
  }) async {
    print('📦 [CART_BLOC] پیش‌تایید سفارش: تاریخ=$deliveryDate, ساعت=$deliveryTime');
    try {
      final result = await _repository.preCheckout(
        transactionType: transactionType,
        deliveryDate: deliveryDate,
        deliveryTime: deliveryTime,
        merchantId: merchantId,
      );
      print('✅ [CART_BLOC] پیش‌تایید با موفقیت انجام شد');
      return result;
    } catch (e) {
      print('❌ [CART_BLOC] خطا در پیش‌تایید: $e');
      return Left(ServerFailure(e.toString()));
    }
  }


// ==================== متد جدید برای دریافت روش‌های پرداخت ====================

Future<Either<Failure, List<PaymentMethodDto>>> getPaymentList(String merchantId, double lat, double lng) async {
  debugPrint('💳 [CART_BLOC] دریافت لیست روش‌های پرداخت');
  try {
    final result = await _repository.getPaymentList(merchantId, lat, lng);
    debugPrint('✅ [CART_BLOC] تعداد روش‌های پرداخت: ${result.fold((l) => 0, (r) => r.length)}');
    return result;
  } catch (e) {
    debugPrint('❌ [CART_BLOC] خطا در دریافت روش‌های پرداخت: $e');
    return Left(ServerFailure(e.toString()));
  }
}


  Future<Either<Failure, PayNowResponseDto>> payNow({
    required String transactionType,
    required String paymentProvider,
    required String deliveryDate,
    required String deliveryTime,
    required String merchantId,
  }) async {
    print('📦 [CART_BLOC] ثبت سفارش نهایی: provider=$paymentProvider');
    try {
      final result = await _repository.payNow(
        transactionType: transactionType,
        paymentProvider: paymentProvider,
        deliveryDate: deliveryDate,
        deliveryTime: deliveryTime,
        merchantId: merchantId,
      );
      print('✅ [CART_BLOC] سفارش ثبت شد: orderId=${result.fold((l) => "", (r) => r.orderId)}');
      return result;
    } catch (e) {
      print('❌ [CART_BLOC] خطا در ثبت سفارش: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}