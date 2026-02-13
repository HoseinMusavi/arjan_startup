import 'package:flutter_bloc/flutter_bloc.dart'; // ✅ اصلاح ایمپورت
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
    await _fetchData(emit);
  }

  Future<void> _onRefreshed(HomeRefreshed event, Emitter<HomeState> emit) async {
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    debugPrint("🏠 HomeBloc: Fetching data started...");

    final results = await Future.wait([
      _repository.getHomeData(),
      _repository.getMerchants(),
    ]);

    final homeDataResult = results[0]; // Either<Failure, Map<String, dynamic>>
    final merchantsResult = results[1]; // Either<Failure, List<MerchantDto>>

    List<String> newBanners = state.banners;
    List<CuisineDto> newCuisines = state.cuisines;
    List<MerchantDto> newMerchants = state.merchants;
    String error = '';

    // --- پردازش دیتای خانه (بنر و دسته‌بندی) ---
    homeDataResult.fold(
      (failure) {
        debugPrint("❌ HomeBloc: Failed to fetch Settings/Banners: ${failure.message}");
        error = failure.message;
      },
      (data) {
        // ✅ رفع خطای Undefined Operator با کستینگ صریح
        final mapData = data as Map<String, dynamic>;
        
        debugPrint("✅ HomeBloc: Banners & Cuisines fetched successfully.");
        
        // پارس کردن ایمن لیست‌ها
        if (mapData['banners'] != null) {
          newBanners = (mapData['banners'] as List).map((e) => e.toString()).toList();
        }
        
        if (mapData['cuisines'] != null) {
          newCuisines = (mapData['cuisines'] as List).cast<CuisineDto>().toList();
        }
      },
    );

    // --- پردازش دیتای رستوران‌ها ---
    merchantsResult.fold(
      (failure) {
        debugPrint("❌ HomeBloc: Failed to fetch Merchants: ${failure.message}");
      },
      (data) {
        // باز کردن دیتا چون داینامیک است
        final merchantList = data as List<MerchantDto>;
        debugPrint("✅ HomeBloc: Merchants fetched successfully. Count: ${merchantList.length}");
        newMerchants = merchantList;
      },
    );

    if (error.isNotEmpty && newBanners.isEmpty && newCuisines.isEmpty && newMerchants.isEmpty) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: error));
    } else {
      emit(state.copyWith(
        status: HomeStatus.success,
        banners: newBanners,
        cuisines: newCuisines,
        merchants: newMerchants,
      ));
    }
  }
}