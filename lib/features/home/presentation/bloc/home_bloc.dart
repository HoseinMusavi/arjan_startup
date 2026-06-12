import 'dart:async';
import 'package:arjan_startup/core/error/failures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../data/models/cuisine_dto.dart';
import '../../data/models/merchant_dto.dart';
import '../../data/models/search_item_dto.dart';
import '../../data/models/promo_item_dto.dart';
import '../../domain/repositories/home_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;

  HomeBloc(this._repository) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
    on<HomeSearchSubmitted>(_onSearchSubmitted);
    on<HomeSearchCleared>(_onSearchCleared);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    if (state.status == HomeStatus.success) return;
    await _fetchAllData(emit, cuisineId: event.cuisineId);
  }

  Future<void> _onRefreshed(HomeRefreshed event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
      searchStatus: SearchStatus.idle,
      searchResults: const [],
      searchQuery: '',
    ));
    await _fetchAllData(emit, cuisineId: event.cuisineId);
  }

  Future<void> _fetchAllData(Emitter<HomeState> emit, {String? cuisineId}) async {
    emit(state.copyWith(status: HomeStatus.loading));
    debugPrint("🏠 HomeBloc: Starting Parallel Fetch... (cuisineId: $cuisineId)");

    const currentLat = 30.5882768;
    const currentLng = 50.2575974;

    final searchType = cuisineId != null && cuisineId.isNotEmpty ? 'byCuisine' : 'byLatLong';
    debugPrint("🏠 HomeBloc: searchType=$searchType, cuisineId=$cuisineId");

    final results = await Future.wait([
      _repository.getBanners(),
      _repository.getCuisines(currentLat, currentLng),
      _repository.getMerchants(searchType, currentLat, currentLng, cuisineId: cuisineId),
      _repository.getMerchants("special_Offers", currentLat, currentLng, cuisineId: cuisineId),
      _repository.getMerchants("featuredMerchant", currentLat, currentLng, cuisineId: cuisineId),
      _repository.getMerchants("allMerchant", currentLat, currentLng, cuisineId: cuisineId),
      _repository.getFavoriteMerchants(lat: currentLat, lng: currentLng),
    ]);

    List<String> banners = [];
    List<CuisineDto> cuisines = [];
    List<MerchantDto> nearby = [];
    List<MerchantDto> offers = [];
    List<MerchantDto> featured = [];
    List<MerchantDto> all = [];
    List<MerchantDto> favorites = [];

    (results[0] as Either<Failure, List<String>>).fold((l) {}, (r) => banners = r);
    (results[1] as Either<Failure, List<CuisineDto>>).fold((l) {}, (r) => cuisines = r);
    if (cuisineId == null || cuisineId.isEmpty) {
      final oldCount = cuisines.length;
      cuisines = cuisines.where((c) => c.id != '59').toList();
      debugPrint("🏠 HomeBloc: فیلتر دسته‌بندی‌ها - حذف سوپرمارکت (id=59): $oldCount → ${cuisines.length}");
    }
    (results[2] as Either<Failure, List<MerchantDto>>).fold((l) {}, (r) => nearby = r);
    (results[3] as Either<Failure, List<MerchantDto>>).fold((l) {}, (r) => offers = r);
    (results[4] as Either<Failure, List<MerchantDto>>).fold((l) {}, (r) => featured = r);
    (results[5] as Either<Failure, List<MerchantDto>>).fold((l) {}, (r) => all = r);
    (results[6] as Either<Failure, List<MerchantDto>>).fold((l) {}, (r) => favorites = r);

    if (cuisineId == null || cuisineId.isEmpty) {
      nearby = nearby.where((m) => !m.cuisineText.contains('سوپرمارکت')).toList();
      offers = offers.where((m) => !m.cuisineText.contains('سوپرمارکت')).toList();
      featured = featured.where((m) => !m.cuisineText.contains('سوپرمارکت')).toList();
      all = all.where((m) => !m.cuisineText.contains('سوپرمارکت')).toList();
      favorites = favorites.where((m) => !m.cuisineText.contains('سوپرمارکت')).toList();
    }

    final promoResult = await _repository.getFoodPromo(lat: currentLat, lng: currentLng);
    List<PromoItemDto> promoItems = [];
    promoResult.fold((l) {}, (r) => promoItems = r.items);
    debugPrint("🎁 تعداد تخفیف‌ها: ${promoItems.length}");

    debugPrint("✅ Home Data Ready: ${banners.length} Banners, ${cuisines.length} Cuisines, ${nearby.length} Nearby, ${favorites.length} Favorites");

    emit(state.copyWith(
      status: HomeStatus.success,
      banners: banners,
      cuisines: cuisines,
      nearbyMerchants: nearby,
      specialOffers: offers,
      featuredMerchants: featured,
      allMerchants: all,
      favoriteMerchants: favorites,
      promoItems: promoItems,
    ));
  }

  Future<void> _onSearchSubmitted(HomeSearchSubmitted event, Emitter<HomeState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(searchStatus: SearchStatus.idle, searchResults: const [], searchQuery: ''));
      return;
    }
    emit(state.copyWith(searchStatus: SearchStatus.loading, searchQuery: event.query));
    debugPrint("🔍 جستجو برای: ${event.query}");
    final result = await _repository.searchMerchantFood(query: event.query, lat: event.lat, lng: event.lng);
    result.fold(
      (failure) => emit(state.copyWith(searchStatus: SearchStatus.failure, searchErrorMessage: failure.message)),
      (response) {
        if (response.isSuccess && response.items.isNotEmpty) {
          emit(state.copyWith(searchStatus: SearchStatus.success, searchResults: response.items));
        } else {
          emit(state.copyWith(searchStatus: SearchStatus.empty, searchResults: const []));
        }
      },
    );
  }

  void _onSearchCleared(HomeSearchCleared event, Emitter<HomeState> emit) {
    emit(state.copyWith(searchStatus: SearchStatus.idle, searchResults: const [], searchQuery: ''));
    debugPrint("🧹 جستجو پاک شد");
  }

  @override
  Future<void> close() {
    return super.close();
  }
}