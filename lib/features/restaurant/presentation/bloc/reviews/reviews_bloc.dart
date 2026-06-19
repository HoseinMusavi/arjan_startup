import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:arjan_startup/core/error/failures.dart';
import 'package:arjan_startup/features/restaurant/domain/repositories/restaurant_repository.dart';
import 'package:arjan_startup/features/restaurant/data/models/review_dto.dart';

part 'reviews_event.dart';
part 'reviews_state.dart';

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  final RestaurantRepository _repository;

  ReviewsBloc(this._repository) : super(const ReviewsState()) {
    on<LoadReviews>(_onLoadReviews);
  }

  Future<void> _onLoadReviews(LoadReviews event, Emitter<ReviewsState> emit) async {
    debugPrint('📝 [ReviewsBloc] بارگذاری نظرات برای فروشگاه: ${event.merchantId}');
    emit(state.copyWith(status: ReviewsStatus.loading));

    final result = await _repository.getReviews(
      merchantId: event.merchantId,
      lat: event.lat,
      lng: event.lng,
    );

    result.fold(
      (failure) {
        debugPrint('❌ [ReviewsBloc] خطا: ${failure.message}');
        emit(state.copyWith(
          status: ReviewsStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (response) {
        if (response.isEmpty) {
          debugPrint('📭 [ReviewsBloc] هیچ نظری موجود نیست');
          emit(state.copyWith(
            status: ReviewsStatus.empty,
            reviews: const [],
          ));
        } else {
          debugPrint('✅ [ReviewsBloc] ${response.reviews.length} نظر دریافت شد');
          emit(state.copyWith(
            status: ReviewsStatus.success,
            reviews: response.reviews,
          ));
        }
      },
    );
  }
}