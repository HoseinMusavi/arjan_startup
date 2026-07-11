import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:arjan_startup/core/error/failures.dart';
import 'package:arjan_startup/features/restaurant/domain/repositories/restaurant_repository.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final RestaurantRepository _repository;

  FavoriteBloc(this._repository) : super(const FavoriteState()) {
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<FavoriteState> emit) async {
    debugPrint('❤️ [FavoriteBloc] تغییر وضعیت علاقه‌مندی برای فروشگاه: ${event.merchantId}');
    emit(state.copyWith(status: FavoriteStatus.loading));

    final result = await _repository.toggleFavorite(
      merchantId: event.merchantId,
      lat: event.lat,
      lng: event.lng,
    );

    result.fold(
      (failure) {
        debugPrint('❌ [FavoriteBloc] خطا: ${failure.message}');
        emit(state.copyWith(
          status: FavoriteStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (data) {
        final isFavorite = data['added'] as bool? ?? false;
        debugPrint('✅ [FavoriteBloc] وضعیت جدید: ${isFavorite ? 'افزوده شد' : 'حذف شد'}');
        emit(state.copyWith(
          status: FavoriteStatus.success,
          isFavorite: isFavorite,
          message: data['message'] ?? '',
        ));
      },
    );
  }
}