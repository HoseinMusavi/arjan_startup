import 'package:equatable/equatable.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object> get props => [];
}

class RestaurantStarted extends RestaurantEvent {
  final String merchantId;
  final double lat;
  final double lng;

  const RestaurantStarted(this.merchantId, this.lat, this.lng);

  @override
  List<Object> get props => [merchantId, lat, lng];
}

class CategoryChanged extends RestaurantEvent {
  final String categoryId;

  const CategoryChanged(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}