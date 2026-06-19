part of 'restaurant_bloc.dart';

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

class LoadItemDetails extends RestaurantEvent {
  final String merchantId;
  final String itemId;
  final String categoryId;
  final double lat;
  final double lng;
  const LoadItemDetails({
    required this.merchantId,
    required this.itemId,
    required this.categoryId,
    required this.lat,
    required this.lng,
  });
  @override
  List<Object> get props => [merchantId, itemId, categoryId, lat, lng];
}

class SearchMenu extends RestaurantEvent {
  final String query;
  const SearchMenu(this.query);
  @override
  List<Object> get props => [query];
}

class ClearSearch extends RestaurantEvent {
  const ClearSearch();
}