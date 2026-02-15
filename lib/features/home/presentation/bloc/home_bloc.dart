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
    await _fetchAllData(emit);
  }

  Future<void> _onRefreshed(HomeRefreshed event, Emitter<HomeState> emit) async {
    await _fetchAllData(emit);
  }

  Future<void> _fetchAllData(Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    debugPrint("🏠 HomeBloc: Starting Parallel Fetch...");

    // اجرای همزمان تمام درخواست‌ها برای سرعت بالا
    final results = await Future.wait([
      _repository.getHomeData(),                  // 0: بنرها
      _repository.getCuisines(),                  // 1: دسته‌بندی‌ها
      _repository.getMerchants("byLatLong"),      // 2: نزدیک‌ترین‌ها
      _repository.getMerchants("special_Offers"), // 3: پیشنهادات ویژه
      _repository.getMerchants("featuredMerchant"),// 4: برگزیده‌ها
      _repository.getMerchants("allMerchant"),    // 5: همه رستوران‌ها
    ]);

    // استخراج نتایج
    List<String> banners = [];
    List<CuisineDto> cuisines = [];
    List<MerchantDto> nearby = [];
    List<MerchantDto> offers = [];
    List<MerchantDto> featured = [];
    List<MerchantDto> all = [];

    (results[0] as dynamic).fold((l) {}, (r) => banners = (r['banners'] as List).map((e) => e.toString()).toList());
    (results[1] as dynamic).fold((l) {}, (r) => cuisines = r);
    (results[2] as dynamic).fold((l) {}, (r) => nearby = r);
    (results[3] as dynamic).fold((l) {}, (r) => offers = r);
    (results[4] as dynamic).fold((l) {}, (r) => featured = r);
    (results[5] as dynamic).fold((l) {}, (r) => all = r);

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