part of 'reviews_bloc.dart';

enum ReviewsStatus { initial, loading, success, empty, failure }

class ReviewsState extends Equatable {
  final ReviewsStatus status;
  final List<ReviewDto> reviews;
  final String errorMessage;

  const ReviewsState({
    this.status = ReviewsStatus.initial,
    this.reviews = const [],
    this.errorMessage = '',
  });

  ReviewsState copyWith({
    ReviewsStatus? status,
    List<ReviewDto>? reviews,
    String? errorMessage,
  }) {
    return ReviewsState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reviews, errorMessage];
}