part of 'reviews_bloc.dart';

abstract class ReviewsEvent extends Equatable {
  const ReviewsEvent();
  @override
  List<Object> get props => [];
}

class LoadReviews extends ReviewsEvent {
  final String merchantId;
  final double lat;
  final double lng;
  const LoadReviews({required this.merchantId, required this.lat, required this.lng});
  @override
  List<Object> get props => [merchantId, lat, lng];
}