import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:arjan_startup/core/error/failures.dart';
import 'package:arjan_startup/features/restaurant/domain/repositories/restaurant_repository.dart';
import 'package:arjan_startup/features/restaurant/data/models/restaurant_info_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_category_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_item_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/item_details_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/search_category_item_dto.dart';

part 'restaurant_event.dart';
part 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final RestaurantRepository _repository;

  String _currentMerchantId = '';
  double _currentLat = 0.0;
  double _currentLng = 0.0;

  RestaurantBloc(this._repository) : super(const RestaurantState()) {
    on<RestaurantStarted>(_onStarted);
    on<CategoryChanged>(_onCategoryChanged);
    on<LoadItemDetails>(_onLoadItemDetails);
    on<SearchMenu>(_onSearchMenu);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onStarted(RestaurantStarted event, Emitter<RestaurantState> emit) async {
    debugPrint('🚀 [RestaurantBloc] استارت برای فروشگاه: ${event.merchantId}');
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
      (failure) => debugPrint('⚠️ [RestaurantBloc] خطا در لود دسته‌بندی‌ها'),
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
    debugPrint('🔄 [RestaurantBloc] تغییر دسته‌بندی به: ${event.categoryId}');
    // ریست کردن وضعیت جستجو و نمایش آیتم‌های دسته‌بندی جدید
    emit(state.copyWith(
      selectedCategoryId: event.categoryId,
      menuStatus: MenuLoadingStatus.loading,
      searchMenuStatus: SearchMenuStatus.idle,
      searchResults: const [],
      searchQuery: '',
    ));
    debugPrint('🔄 [RestaurantBloc] وضعیت جستجو ریست شد، در حال دریافت آیتم‌ها...');

    final itemsResult = await _repository.getItemsByCategory(_currentMerchantId, event.categoryId, _currentLat, _currentLng);

    itemsResult.fold(
      (failure) => emit(state.copyWith(menuStatus: MenuLoadingStatus.failure, errorMessage: failure.message)),
      (data) {
        debugPrint('✅ [RestaurantBloc] ${data.length} آیتم برای دسته‌بندی ${event.categoryId} دریافت شد');
        emit(state.copyWith(menuStatus: MenuLoadingStatus.success, items: data));
      },
    );
  }

  Future<void> _onLoadItemDetails(LoadItemDetails event, Emitter<RestaurantState> emit) async {
    debugPrint('🍽️ [RestaurantBloc] دریافت جزئیات غذا: ${event.itemId}');
    emit(state.copyWith(itemDetailsStatus: ItemDetailsStatus.loading));
    final result = await _repository.getItemDetails(
      event.merchantId,
      event.itemId,
      event.categoryId,
      event.lat,
      event.lng,
    );
    result.fold(
      (failure) => emit(state.copyWith(itemDetailsStatus: ItemDetailsStatus.failure, errorMessage: failure.message)),
      (data) => emit(state.copyWith(itemDetailsStatus: ItemDetailsStatus.success, selectedItem: data)),
    );
  }

  Future<void> _onSearchMenu(SearchMenu event, Emitter<RestaurantState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(searchMenuStatus: SearchMenuStatus.idle, searchResults: const [], searchQuery: ''));
      return;
    }
    debugPrint('🔍 [RestaurantBloc] جستجو: "${event.query}" در فروشگاه $_currentMerchantId');
    emit(state.copyWith(searchMenuStatus: SearchMenuStatus.loading, searchQuery: event.query));
    final result = await _repository.searchFoodCategory(
      query: event.query,
      merchantId: _currentMerchantId,
      lat: _currentLat,
      lng: _currentLng,
    );
    result.fold(
      (failure) => emit(state.copyWith(searchMenuStatus: SearchMenuStatus.failure, errorMessage: failure.message)),
      (response) {
        debugPrint('📦 [RestaurantBloc] تعداد دسته‌بندی‌های یافت شده: ${response.items.length}');
        if (response.isSuccess && response.items.isNotEmpty) {
          emit(state.copyWith(searchMenuStatus: SearchMenuStatus.success, searchResults: response.items));
        } else {
          emit(state.copyWith(searchMenuStatus: SearchMenuStatus.empty, searchResults: const []));
        }
      },
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<RestaurantState> emit) {
    debugPrint('🧹 [RestaurantBloc] پاک کردن جستجو');
    emit(state.copyWith(searchMenuStatus: SearchMenuStatus.idle, searchResults: const [], searchQuery: ''));
  }

  @override
  Future<void> close() {
    return super.close();
  }
}