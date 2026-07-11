part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

class HomeStarted extends HomeEvent {
  final String? cuisineId;
  const HomeStarted({this.cuisineId});
  @override
  List<Object> get props => [cuisineId ?? ''];
}

class HomeRefreshed extends HomeEvent {
  final String? cuisineId;
  const HomeRefreshed({this.cuisineId});
  @override
  List<Object> get props => [cuisineId ?? ''];
}

class HomeSearchSubmitted extends HomeEvent {
  final String query;
  final double lat;
  final double lng;
  const HomeSearchSubmitted({required this.query, required this.lat, required this.lng});
  @override
  List<Object> get props => [query, lat, lng];
}

class HomeSearchCleared extends HomeEvent {
  const HomeSearchCleared();
}