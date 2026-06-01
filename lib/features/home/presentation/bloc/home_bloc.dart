import 'package:arjan_startup/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/cuisine_dto.dart';
import '../../data/models/merchant_dto.dart';
import '../../domain/repositories/home_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;

  HomeBloc(this._repository) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    if (state.status == HomeStatus.success) return;
    await _fetchAllData(emit, cuisineId: event.cuisineId);
  }

  Future<void> _onRefreshed(HomeRefreshed event, Emitter<HomeState> emit) async {
    await _fetchAllData(emit, cuisineId: event.cuisineId);
  }

  Future<void> _fetchAllData(Emitter<HomeState> emit, {String? cuisineId}) async {
    emit(state.copyWith(status: HomeStatus.loading));
    debugPrint("🏠 HomeBloc: Starting Parallel Fetch... (cuisineId: $cuisineId)");

    double currentLat = 30.5882768;
    double currentLng = 50.2575974;
    
    final searchType = cuisineId != null && cuisineId.isNotEmpty ? 'byCuisine' : 'byLatLong';
    debugPrint("🏠 HomeBloc: searchType=$searchType, cuisineId=$cuisineId");

    final results = await Future.wait([
      _repository.getBanners(),
      _repository.getCuisines(currentLat, currentLng),
      _repository.getMerchants(searchType, currentLat, currentLng, cuisineId: cuisineId),
      _repository.getMerchants("special_Offers", currentLat, currentLng, cuisineId: cuisineId),
      _repository.getMerchants("featuredMerchant", currentLat, currentLng, cuisineId: cuisineId),
      _repository.getMerchants("allMerchant", currentLat, currentLng, cuisineId: cuisineId),
    ]);

    List<String> banners = [];
    List<CuisineDto> cuisines = [];
    List<MerchantDto> nearby = [];
    List<MerchantDto> offers = [];
    List<MerchantDto> featured = [];
    List<MerchantDto> all = [];

    (results[0] as Either<Failure, List<String>>).fold((l) {}, (r) => banners = r);
    
    // ✅ فیلتر دسته‌بندی‌ها: حذف سوپرمارکت (id=59)
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

    // ✅ فیلتر فروشگاه‌های سوپرمارکت بر اساس cuisineText
    if (cuisineId == null || cuisineId.isEmpty) {
      debugPrint("🏠 HomeBloc: شروع فیلتر سوپرمارکت‌ها بر اساس cuisineText...");
      
      final oldNearbyCount = nearby.length;
      nearby = nearby.where((m) {
        final isSupermarket = m.cuisineText.contains('سوپرمارکت');
        if (isSupermarket) debugPrint("   🗑️ حذف شد (سوپرمارکت): ${m.name}");
        return !isSupermarket;
      }).toList();
      debugPrint("   📊 nearby: $oldNearbyCount → ${nearby.length}");
      
      final oldOffersCount = offers.length;
      offers = offers.where((m) => !m.cuisineText.contains('سوپرمارکت')).toList();
      debugPrint("   📊 offers: $oldOffersCount → ${offers.length}");
      
      final oldFeaturedCount = featured.length;
      featured = featured.where((m) => !m.cuisineText.contains('سوپرمارکت')).toList();
      debugPrint("   📊 featured: $oldFeaturedCount → ${featured.length}");
      
      final oldAllCount = all.length;
      all = all.where((m) => !m.cuisineText.contains('سوپرمارکت')).toList();
      debugPrint("   📊 all: $oldAllCount → ${all.length}");
      
      debugPrint("🏠 HomeBloc: پس از فیلتر - ${nearby.length} رستوران نزدیک");
    }

    debugPrint("✅ Home Data Ready: ${banners.length} Banners, ${cuisines.length} Cuisines, ${nearby.length} Nearby");

    emit(state.copyWith(
      status: HomeStatus.success,
      banners: banners,
      cuisines: cuisines,
      nearbyMerchants: nearby,
      specialOffers: offers,
      featuredMerchants: featured,
      allMerchants: all,
    ));
  }
}