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
    await _fetchAllData(emit);
  }

  Future<void> _onRefreshed(HomeRefreshed event, Emitter<HomeState> emit) async {
    await _fetchAllData(emit);
  }

  Future<void> _fetchAllData(Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    debugPrint("🏠 HomeBloc: Starting Parallel Fetch...");

    // عرض و طول جغرافیایی فعلاً ثابت در نظر گرفته شده است (بر اساس لاگ شما).
    // در آینده این مقادیر را از سرویس لوکیشن گوشی دریافت می‌کنیم.
    double currentLat = 30.5882768;
    double currentLng = 50.2575974;

    // اجرای همزمان تمام درخواست‌ها برای سرعت بالا
    final results = await Future.wait([
      _repository.getBanners(),                                            // 0: بنرها
      _repository.getCuisines(),                                           // 1: دسته‌بندی‌ها
      _repository.getMerchants("byLatLong", currentLat, currentLng),       // 2: نزدیک‌ترین‌ها
      _repository.getMerchants("special_Offers", currentLat, currentLng),  // 3: پیشنهادات ویژه
      _repository.getMerchants("featuredMerchant", currentLat, currentLng),// 4: برگزیده‌ها
      _repository.getMerchants("allMerchant", currentLat, currentLng),     // 5: همه رستوران‌ها
    ]);

    // استخراج نتایج
    List<String> banners = [];
    List<CuisineDto> cuisines = [];
    List<MerchantDto> nearby = [];
    List<MerchantDto> offers = [];
    List<MerchantDto> featured = [];
    List<MerchantDto> all = [];

    (results[0] as Either<Failure, List<String>>).fold((l) {}, (r) => banners = r);
    (results[1] as Either<Failure, List<CuisineDto>>).fold((l) {}, (r) => cuisines = r);
    (results[2] as Either<Failure, List<MerchantDto>>).fold((l) {}, (r) => nearby = r);
    (results[3] as Either<Failure, List<MerchantDto>>).fold((l) {}, (r) => offers = r);
    (results[4] as Either<Failure, List<MerchantDto>>).fold((l) {}, (r) => featured = r);
    (results[5] as Either<Failure, List<MerchantDto>>).fold((l) {}, (r) => all = r);

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