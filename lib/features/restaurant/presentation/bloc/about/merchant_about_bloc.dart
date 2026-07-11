import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:arjan_startup/core/error/failures.dart';
import 'package:arjan_startup/features/restaurant/domain/repositories/restaurant_repository.dart';
import 'package:arjan_startup/features/restaurant/data/models/merchant_about_dto.dart';

part 'merchant_about_event.dart';
part 'merchant_about_state.dart';

class MerchantAboutBloc extends Bloc<MerchantAboutEvent, MerchantAboutState> {
  final RestaurantRepository _repository;

  MerchantAboutBloc(this._repository) : super(const MerchantAboutState()) {
    on<LoadMerchantAbout>(_onLoadMerchantAbout);
  }

  Future<void> _onLoadMerchantAbout(
    LoadMerchantAbout event,
    Emitter<MerchantAboutState> emit,
  ) async {
    debugPrint('📋 [AboutBloc] بارگذاری اطلاعات رستوران: ${event.merchantId}');
    emit(state.copyWith(status: MerchantAboutStatus.loading));

    final result = await _repository.getMerchantAbout(
      merchantId: event.merchantId,
      lat: event.lat,
      lng: event.lng,
    );

    result.fold(
      (failure) {
        debugPrint('❌ [AboutBloc] خطا: ${failure.message}');
        emit(state.copyWith(
          status: MerchantAboutStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (about) {
        debugPrint('✅ [AboutBloc] اطلاعات دریافت شد: ${about.data.restaurantName}');
        emit(state.copyWith(
          status: MerchantAboutStatus.success,
          about: about,
        ));
      },
    );
  }
}