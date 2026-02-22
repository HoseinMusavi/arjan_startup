import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';

// آدرس‌دهی مطلق ریپازیتوری و مدل‌ها
import 'package:arjan_startup/features/restaurant/domain/repositories/restaurant_repository.dart';
import 'package:arjan_startup/features/restaurant/data/models/restaurant_info_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_category_dto.dart';

// ✅ استفاده از ایمپورت و اکسپورت به جای part
import 'restaurant_event.dart';
import 'restaurant_state.dart';

export 'restaurant_event.dart';
export 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final RestaurantRepository _repository;
  
  String _currentMerchantId = '';
  double _currentLat = 0.0;
  double _currentLng = 0.0;

  RestaurantBloc(this._repository) : super(const RestaurantState()) {
    on<RestaurantStarted>(_onStarted);
    on<CategoryChanged>(_onCategoryChanged);
  }

  Future<void> _onStarted(RestaurantStarted event, Emitter<RestaurantState> emit) async {
    log('🚀 [RestaurantBloc] استارت برای فروشگاه: ${event.merchantId}');
    _currentMerchantId = event.merchantId;
    _currentLat = event.lat;
    _currentLng = event.lng;

    emit(state.copyWith(status: RestaurantStatus.loading));

    final infoResult = await _repository.getRestaurantInfo(_currentMerchantId, _currentLat, _currentLng);
    final categoriesResult = await _repository.getMenuCategories(_currentMerchantId, _currentLat, _currentLng);

    RestaurantInfoDto? info;
    List<MenuCategoryDto> categories = [];
    String initialCatId = '';

    infoResult.fold(
      (failure) => emit(state.copyWith(status: RestaurantStatus.failure, errorMessage: failure.message)),
      (data) => info = data,
    );

    categoriesResult.fold(
      (failure) => log('⚠️ [RestaurantBloc] خطا در لود دسته‌بندی‌ها'), 
      (data) {
        categories = data;
        if (categories.isNotEmpty) {
          initialCatId = categories.first.id;
        }
      }
    );

    if (info != null) {
      emit(state.copyWith(
        status: RestaurantStatus.success,
        info: info,
        categories: categories,
        selectedCategoryId: initialCatId,
        menuStatus: MenuLoadingStatus.loading,
      ));
      
      if (initialCatId.isNotEmpty) {
        add(CategoryChanged(initialCatId));
      } else {
        emit(state.copyWith(menuStatus: MenuLoadingStatus.success, items: []));
      }
    }
  }

  Future<void> _onCategoryChanged(CategoryChanged event, Emitter<RestaurantState> emit) async {
    emit(state.copyWith(selectedCategoryId: event.categoryId, menuStatus: MenuLoadingStatus.loading));
    
    final itemsResult = await _repository.getItemsByCategory(_currentMerchantId, event.categoryId, _currentLat, _currentLng);
    
    itemsResult.fold(
      (failure) => emit(state.copyWith(menuStatus: MenuLoadingStatus.failure, errorMessage: failure.message)),
      (data) => emit(state.copyWith(menuStatus: MenuLoadingStatus.success, items: data)),
    );
  }
}