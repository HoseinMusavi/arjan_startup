part of 'favorite_bloc.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();
  @override
  List<Object> get props => [];
}

class ToggleFavorite extends FavoriteEvent {
  final String merchantId;
  final double lat;
  final double lng;
  const ToggleFavorite({required this.merchantId, required this.lat, required this.lng});
  @override
  List<Object> get props => [merchantId, lat, lng];
}